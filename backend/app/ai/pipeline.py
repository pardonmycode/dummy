import json
from typing import Dict, List, Any, Optional
from app.ai.provider import get_provider, AIResponse
from app.ai.prompts import get_prompt
from app.ai.tools import get_tools
from datetime import datetime

async def run_widget_pipeline(widget_id: str, user_context: Dict, location: Optional[str] = None) -> Dict:
    """
    Run the complete AI pipeline for a widget.
    
    Returns the validated widget JSON structure.
    """
    provider = get_provider()
    prompt_config = get_prompt(widget_id)
    
    # Build messages
    messages = [
        {"role": "system", "content": prompt_config["system"]},
    ]
    
    # Add user context
    user_msg = build_user_message(widget_id, user_context, location)
    messages.append({"role": "user", "content": user_msg})
    
    # Get tools for this widget
    tools = get_tools(prompt_config.get("tools", []))
    
    # Call AI with tool support
    try:
        if tools:
            # Check if provider supports tools (not mock)
            provider_type = type(provider).__name__
            if provider_type == "MockProvider":
                response = await provider.chat(messages)
                result = {"content": response.content, "sources": response.sources}
            else:
                result = await call_with_tools(provider, messages, tools)
        else:
            response = await provider.chat(messages, model=prompt_config.get("model"))
            result = {"content": response.content, "sources": response.sources}
    except Exception as e:
        return {
            "schemaVersion": 1,
            "data": {"error": str(e)},
            "sources": [],
            "generatedAt": datetime.utcnow().isoformat(),
            "status": "error"
        }
    
    # Validate and return widget JSON
    return build_widget_json(widget_id, result, prompt_config)

async def call_with_tools(provider, messages, tools, max_iterations: int = 3) -> Dict:
    """
    Call AI with tool support, iterating until no more tool calls are needed.
    """
    for i in range(max_iterations):
        response = await provider.chat(messages, tools=tools)
        if not response.tool_calls:
            return {"content": response.content, "sources": response.sources}
        
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
    
    return {"content": "Max iterations reached", "sources": []}

async def execute_tool(tool_name: str, args: Dict) -> Dict:
    """Execute a tool and return its result."""
    try:
        if tool_name == "get_weather":
            return await get_weather(args.get("city", ""), args.get("country", "DE"))
        elif tool_name == "web_search":
            return {"results": [], "message": "Web search not configured"}
        elif tool_name == "geocode":
            return {"lat": 0, "lon": 0, "message": "Geocoding not configured"}
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