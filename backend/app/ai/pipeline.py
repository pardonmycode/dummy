import json
from typing import Dict, List, Any, Optional
from app.ai.provider import get_provider, AIResponse
from app.ai.prompts import get_prompt
from app.ai.tools import get_tools
from app.ai.cache import get_cached, set_cached
from app.ai.validation import validate_widget_data, repair_json, has_sources
from app.ai.tracing import start_trace, add_trace_step, complete_trace
from datetime import datetime

# Token and cost tracking
token_usage: Dict[str, Dict] = {}

async def run_widget_pipeline(widget_id: str, user_context: Dict, location: Optional[str] = None, force_refresh: bool = False) -> Dict:
    """
    Run the complete AI pipeline for a widget.
    
    Returns the validated widget JSON structure.
    """
    user_id = user_context.get("user_id", 0)
    
    # Start trace
    trace_id = start_trace(user_id, widget_id, None)
    
    try:
        # Check cache
        cache_key_params = {"location": location, "user_id": user_id}
        if not force_refresh:
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
        try:
            if tools:
                provider_type = type(provider).__name__
                if provider_type == "MockProvider":
                    response = await provider.chat(messages)
                    result = {"content": response.content, "sources": response.sources}
                else:
                    result = await call_with_tools(provider, messages, tools)
            else:
                response = await provider.chat(messages, model=prompt_config.get("model"))
                result = {"content": response.content, "sources": response.sources}
            
            add_trace_step(trace_id, "ai_response", {"tokens": result.get("tokens_used", 0)})
            
            # Track token usage
            tokens_used = result.get("tokens_used", 0)
            if user_id not in token_usage:
                token_usage[user_id] = {"tokens": 0, "requests": 0}
            token_usage[user_id]["tokens"] += tokens_used
            token_usage[user_id]["requests"] += 1
            
        except Exception as e:
            add_trace_step(trace_id, "error", {"error": str(e)})
            return {
                "schemaVersion": 1,
                "data": {"error": str(e)},
                "sources": [],
                "generatedAt": datetime.utcnow().isoformat(),
                "status": "error"
            }
        
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
            "generatedAt": datetime.utcnow().isoformat(),
            "status": "error"
        }

async def call_with_tools(provider, messages, tools, max_iterations: int = 3) -> Dict:
    """
    Call AI with tool support, iterating until no more tool calls are needed.
    """
    total_tokens = 0
    for i in range(max_iterations):
        response = await provider.chat(messages, tools=tools)
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
            return {"results": [{"title": "Mock Result", "url": "https://example.com"}]}
        elif tool_name == "geocode":
            return {"lat": 52.52, "lon": 13.405, "city": args.get("address", "Berlin")}
        elif tool_name == "get_tracker_data":
            return {"data": [], "message": "No tracker data available"}
        elif tool_name == "get_food_nutrition":
            return {"protein": 0, "carbs": 0, "fat": 0, "calories": 0}
        else:
            return {"error": f"Unknown tool: {tool_name}"}
    except Exception as e:
        return {"error": str(e)}

async def get_weather(city: str, country: str) -> Dict:
    """Get weather from OpenWeatherMap API."""
    import httpx
    from app.config import settings
    
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
    params = {
        "q": f"{city},{country}",
        "appid": settings.OPENWEATHER_API_KEY,
        "units": "metric",
        "lang": "de"
    }
    
    async with httpx.AsyncClient() as client:
        response = await client.get(url, params=params)
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

def build_user_message(widget_id: str, user_context: Dict, location: Optional[str]) -> str:
    """Build the user message for the AI."""
    if widget_id == "weather_summary":
        return f"Wetter in {location or user_context.get('location', 'Berlin')} bitte."
    elif widget_id == "party_recommendations":
        return f"Partys in {location or user_context.get('location', 'Berlin')} heute Abend."
    elif widget_id == "health_insights":
        return f"Einsichten für meine Tracker-Daten: {json.dumps(user_context.get('tracker', {}))}"
    elif widget_id == "meal_suggestions":
        return f"Mahlzeitvorschläge für meine Ziele: {json.dumps(user_context.get('goals', {}))}"
    else:
        return "Aktualisiere deine Daten."

def build_widget_json(widget_id: str, result: Dict, prompt_config: Dict) -> Dict:
    """Build the final widget JSON structure."""
    return {
        "schemaVersion": 1,
        "data": result.get("content", ""),
        "sources": result.get("sources", []),
        "generatedAt": datetime.utcnow().isoformat(),
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