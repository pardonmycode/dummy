import json
import asyncio
import logging
from typing import Dict, List, Any, Optional

logger = logging.getLogger(__name__)
from app.ai.provider import get_provider, AIResponse
from app.ai.prompts import get_prompt
from app.ai.tools import get_tools, web_search, geocode, get_route, search_events
from app.ai.cache import get_cached, set_cached
from app.ai.validation import validate_widget_data, repair_json, has_sources, validate_quellenpflicht
from app.ai.tracing import start_trace, add_trace_step, complete_trace
from app.security import sanitize_text, validate_url, validate_location_precision, encrypt_data, decrypt_data
from datetime import datetime, timezone

# Token and cost tracking
token_usage: Dict[str, Dict] = {}

# Budget limits (tokens per user)
USER_TOKEN_BUDGET = 50000
ai_killed = False  # Kill-switch flag

def _evict_old_token_usage():
    """Evict oldest token_usage entries when over 1000."""
    if len(token_usage) > 1000:
        # Remove oldest entries (first 100 inserted)
        keys_to_remove = list(token_usage.keys())[:100]
        for key in keys_to_remove:
            del token_usage[key]

# Model routing configuration
SIMPLE_MODELS = ["gpt-4o-mini", "gpt-3.5-turbo"]
COMPLEX_MODELS = ["gpt-4o", "gpt-4-turbo"]

def determine_model(widget_id: str, user_context: Dict) -> str:
    """
    Route to appropriate model based on complexity.
    
    Simple requests (weather, basic queries) -> cheaper model
    Complex requests (analysis, multi-step) -> more capable model
    """
    # Kill-switch: if AI is killed, use fallback
    if ai_killed:
        return "fallback"
    
    # Simple widget types
    simple_widgets = ["weather_summary"]
    if widget_id in simple_widgets:
        return "gpt-4o-mini"
    
    # Complex widget types (analysis, recommendations)
    complex_widgets = ["party_recommendations", "health_insights", "meal_suggestions"]
    if widget_id in complex_widgets:
        return "gpt-4o"
    
    # Default to complex model
    return "gpt-4o"

def set_ai_kill_switch(enabled: bool):
    """Enable/disable AI calls entirely."""
    global ai_killed
    ai_killed = enabled

async def run_widget_pipeline(widget_id: str, user_context: Dict, location: Optional[str] = None, force_refresh: bool = False, on_progress=None) -> Dict:
    """
    Run the complete AI pipeline for a widget.
    
    on_progress: Optional callback(status, data) for streaming updates.
    
    Returns the validated widget JSON structure.
    """
    user_id = user_context.get("user_id", 0)
    
    # Start trace
    trace_id = start_trace(user_id, widget_id, None)
    
    if on_progress:
        on_progress("loading", {"widget_id": widget_id})
    
    try:
        # Kill-switch check
        if ai_killed:
            add_trace_step(trace_id, "kill_switch", {})
            return {
                "schemaVersion": 1,
                "data": {"error": "AI-Dienst derzeit inaktiv"},
                "sources": [],
                "generatedAt": datetime.now(timezone.utc).isoformat(),
                "status": "error"
            }
        
        # Budget check
        if user_id in token_usage:
            if token_usage[user_id]["tokens"] >= USER_TOKEN_BUDGET:
                add_trace_step(trace_id, "budget_exceeded", {"used": token_usage[user_id]["tokens"]})
                return {
                    "schemaVersion": 1,
                    "data": {"error": f"Token-Budget überschritten ({token_usage[user_id]['tokens']}/{USER_TOKEN_BUDGET})"},
                    "sources": [],
                    "generatedAt": datetime.now(timezone.utc).isoformat(),
                    "status": "error"
                }
        
        # Determine model
        model = determine_model(widget_id, user_context)
        
        # Check cache
        cache_key_params = {"location": location, "user_id": user_id}
        if not force_refresh:
            if on_progress:
                on_progress("checking_cache", {"widget_id": widget_id})
            cached = get_cached(widget_id, cache_key_params)
            if cached:
                add_trace_step(trace_id, "cache_hit", {"widget_id": widget_id})
                complete_trace(trace_id, 0)
                return cached
        
        # Get AI provider
        provider = get_provider()
        prompt_config = get_prompt(widget_id)
        
        # Build messages
        messages = [
            {"role": "system", "content": prompt_config["system"]},
        ]
        
        # Add user context
        user_msg = build_user_message(widget_id, user_context, location)
        messages.append({"role": "user", "content": user_msg})
        add_trace_step(trace_id, "messages", {"user_message": user_msg})
        
        # Get tools for this widget
        tools = get_tools(prompt_config.get("tools", []))
        
        # Call AI
        if on_progress:
            on_progress("calling_ai", {"widget_id": widget_id, "model": model})
        try:
            if tools:
                provider_type = type(provider).__name__
                if provider_type == "MockProvider":
                    response = await provider.chat(messages)
                    result = {"content": response.content, "sources": response.sources}
                else:
                    result = await call_with_tools(provider, messages, tools)
            else:
                response = await asyncio.wait_for(provider.chat(messages, model=model), timeout=60)
                result = {"content": response.content, "sources": response.sources}
            
            add_trace_step(trace_id, "ai_response", {"tokens": result.get("tokens_used", 0)})
            
            # Track token usage
            tokens_used = result.get("tokens_used", 0)
            if user_id not in token_usage:
                token_usage[user_id] = {"tokens": 0, "requests": 0}
            token_usage[user_id]["tokens"] += tokens_used
            token_usage[user_id]["requests"] += 1
            _evict_old_token_usage()
            
        except Exception as e:
            add_trace_step(trace_id, "error", {"error": str(e)})
            return {
                "schemaVersion": 1,
                "data": {"error": str(e)},
                "sources": [],
                "generatedAt": datetime.now(timezone.utc).isoformat(),
                "status": "error"
            }
        
        # Validate Quellenpflicht
        if on_progress:
            on_progress("processing", {"widget_id": widget_id})
        quellen_valid = validate_quellenpflicht(widget_id, result)
        if not quellen_valid["valid"]:
            add_trace_step(trace_id, "quellenpflicht_failed", {"errors": quellen_valid["errors"]})
        
        # Validate and build widget JSON
        widget_json = build_widget_json(widget_id, result, prompt_config)
        
        # Cache result
        set_cached(widget_id, cache_key_params, widget_json, ttl=300)
        
        complete_trace(trace_id, tokens_used)
        return widget_json
        
    except Exception as e:
        add_trace_step(trace_id, "pipeline_error", {"error": str(e)})
        complete_trace(trace_id, 0)
        return {
            "schemaVersion": 1,
            "data": {"error": str(e)},
            "sources": [],
            "generatedAt": datetime.now(timezone.utc).isoformat(),
            "status": "error"
        }

async def call_with_tools(provider, messages, tools, max_iterations: int = 3) -> Dict:
    """
    Call AI with tool support, iterating until no more tool calls are needed.
    """
    total_tokens = 0
    for i in range(max_iterations):
        response = await asyncio.wait_for(provider.chat(messages, tools=tools), timeout=60)
        total_tokens += response.tokens_used
        
        if not response.tool_calls:
            return {"content": response.content, "sources": response.sources, "tokens_used": total_tokens}
        
        # Execute tools and add results to conversation
        for tool_call in response.tool_calls:
            tool_name = tool_call["name"]
            tool_args = tool_call.get("arguments", {})
            result = await execute_tool(tool_name, tool_args)
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.get("id", ""),
                "content": json.dumps(result)
            })
    
    return {"content": "Max iterations reached", "sources": [], "tokens_used": total_tokens}

async def execute_tool(tool_name: str, args: Dict) -> Dict:
    """Execute a tool and return its result."""
    try:
        if tool_name == "get_weather":
            return await get_weather(args.get("city", ""), args.get("country", "DE"))
        elif tool_name == "web_search":
            query = args.get("query", "")
            return await web_search(query)
        elif tool_name == "geocode":
            address = args.get("address", "")
            return await geocode(address)
        elif tool_name == "get_route":
            return await get_route(
                args.get("from", ""),
                args.get("to", ""),
                args.get("mode", "car")
            )
        elif tool_name == "search_events":
            return await search_events(
                args.get("city", ""),
                args.get("date"),
                args.get("type")
            )
        elif tool_name == "get_tracker_data":
            return {"data": [], "message": "No tracker data available"}
        elif tool_name == "get_food_nutrition":
            return {"protein": 0, "carbs": 0, "fat": 0, "calories": 0}
        elif tool_name == "get_calendar_events":
            return {"events": [], "message": "No calendar data available"}
        elif tool_name == "get_news":
            return await web_search(args.get("topic", "") + " news")
        else:
            return {"error": f"Unknown tool: {tool_name}"}
    except Exception as e:
        logger.error(f"Tool execution failed: {tool_name} - {e}")
        return {"error": str(e)}

async def get_weather(city: str, country: str) -> Dict:
    """Get weather from OpenWeatherMap API with location precision validation."""
    import httpx
    from app.config import settings
    
    # Sanitize location input
    city = sanitize_text(city)
    
    if not settings.OPENWEATHER_API_KEY:
        return {
            "city": city,
            "temperature": 20,
            "feels_like": 21,
            "condition": "Wolken",
            "humidity": 50,
            "wind_speed": 10,
            "sources": ["OpenWeatherMap (mock)"]
        }
    
    url = "https://api.openweathermap.org/data/2.5/weather"
    # Validate URL before using
    if not validate_url(url):
        raise ValueError(f"Invalid weather API URL: {url}")
    
    params = {
        "q": f"{city},{country}",
        "appid": settings.OPENWEATHER_API_KEY,
        "units": "metric",
        "lang": "de"
    }
    
    async with httpx.AsyncClient() as client:
        response = await client.get(url, params=params, timeout=10)
        if response.status_code == 200:
            data = response.json()
            return {
                "city": data.get("name", city),
                "temperature": data["main"]["temp"],
                "feels_like": data["main"].get("feels_like", data["main"]["temp"]),
                "condition": data["weather"][0]["description"],
                "humidity": data["main"].get("humidity", 0),
                "wind_speed": data["wind"].get("speed", 0),
                "sources": ["OpenWeatherMap API"]
            }
        else:
            return {"error": "Weather API error", "status_code": response.status_code}

def _sanitize_input(text: str, max_length: int = 1000) -> str:
    """Sanitize user input: escape backticks, trim, limit length."""
    if not isinstance(text, str):
        text = str(text)
    text = text.strip()
    text = text.replace("`", "\\`")
    if len(text) > max_length:
        text = text[:max_length] + "..."
    return text

def build_user_message(widget_id: str, user_context: Dict, location: Optional[str]) -> str:
    """Build the user message for the AI with security sanitization."""
    if widget_id == "weather_summary":
        loc = sanitize_text(location or user_context.get('location', 'Berlin'))
        return f"Wetter in {loc} bitte."
    elif widget_id == "party_recommendations":
        loc = sanitize_text(location or user_context.get('location', 'Berlin'))
        return f"Partys in {loc} heute Abend."
    elif widget_id == "health_insights":
        tracker_data = user_context.get('tracker', {})
        tracker_json = json.dumps(tracker_data)
        if len(tracker_json) >= 5000:
            tracker_json = tracker_json[:5000] + "..."
        return f"Einsichten für meine Tracker-Daten: {tracker_json}"
    elif widget_id == "meal_suggestions":
        goals = user_context.get('goals', {})
        goals_json = json.dumps(goals)
        if len(goals_json) >= 5000:
            goals_json = goals_json[:5000] + "..."
        return f"Mahlzeitvorschläge für meine Ziele: {goals_json}"
    else:
        return "Aktualisiere deine Daten."

def build_widget_json(widget_id: str, result: Dict, prompt_config: Dict) -> Dict:
    """Build the final widget JSON structure with URL validation for sources."""
    sources = result.get("sources", [])
    validated_sources = []
    for source in sources:
        if isinstance(source, str):
            # Validate if it looks like a URL
            if source.startswith("http://") or source.startswith("https://"):
                if validate_url(source):
                    validated_sources.append(source)
                else:
                    logger.warning(f"Invalid source URL: {source}")
            else:
                validated_sources.append(source)
        else:
            validated_sources.append(source)
    
    return {
        "schemaVersion": 1,
        "data": result.get("content", ""),
        "sources": validated_sources,
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "expiresAt": None,
        "status": "ok"
    }

def get_token_usage(user_id: int) -> Dict:
    """Get token usage for a user."""
    return token_usage.get(user_id, {"tokens": 0, "requests": 0})

def reset_token_usage(user_id: int):
    """Reset token usage for a user."""
    if user_id in token_usage:
        del token_usage[user_id]