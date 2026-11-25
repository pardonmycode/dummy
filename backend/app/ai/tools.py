from typing import Dict, List, Any

# Tool definitions
WEATHER_TOOL = {
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Get current weather and forecast for a location",
        "parameters": {
            "type": "object",
            "properties": {
                "city": {"type": "string", "description": "City name"},
                "country": {"type": "string", "description": "Country code (optional)", "default": "DE"}
            },
            "required": ["city"]
        }
    }
}

WEB_SEARCH_TOOL = {
    "type": "function",
    "function": {
        "name": "web_search",
        "description": "Search the web for information",
        "parameters": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "Search query"}
            },
            "required": ["query"]
        }
    }
}

GEOCODING_TOOL = {
    "type": "function",
    "function": {
        "name": "geocode",
        "description": "Get coordinates for an address or location",
        "parameters": {
            "type": "object",
            "properties": {
                "address": {"type": "string", "description": "Address to geocode"}
            },
            "required": ["address"]
        }
    }
}

TRACKER_DATA_TOOL = {
    "type": "function",
    "function": {
        "name": "get_tracker_data",
        "description": "Get user's tracker data (protein, carbs, water, etc.)",
        "parameters": {
            "type": "object",
            "properties": {
                "type": {"type": "string", "description": "Tracker type (protein, carbs, water, steps, etc.)"}
            },
            "required": ["type"]
        }
    }
}

FOOD_DATABASE_TOOL = {
    "type": "function",
    "function": {
        "name": "get_food_nutrition",
        "description": "Get nutrition facts for a food item",
        "parameters": {
            "type": "object",
            "properties": {
                "food": {"type": "string", "description": "Food name"},
                "amount_g": {"type": "number", "description": "Amount in grams", "default": 100}
            },
            "required": ["food"]
        }
    }
}

EVENTS_TOOL = {
    "type": "function",
    "function": {
        "name": "search_events",
        "description": "Search for events and parties in a location",
        "parameters": {
            "type": "object",
            "properties": {
                "city": {"type": "string", "description": "City name"},
                "date": {"type": "string", "description": "Date (optional, defaults to today)"},
                "type": {"type": "string", "description": "Event type (party, concert, exhibition)"}
            },
            "required": ["city"]
        }
    }
}

MAPS_TOOL = {
    "type": "function",
    "function": {
        "name": "get_route",
        "description": "Get route and travel time between two points",
        "parameters": {
            "type": "object",
            "properties": {
                "from": {"type": "string", "description": "Starting point"},
                "to": {"type": "string", "description": "Destination"},
                "mode": {"type": "string", "description": "Travel mode (car, walk, transit)", "default": "car"}
            },
            "required": ["from", "to"]
        }
    }
}

CALENDAR_TOOL = {
    "type": "function",
    "function": {
        "name": "get_calendar_events",
        "description": "Get upcoming calendar events for the user",
        "parameters": {
            "type": "object",
            "properties": {
                "days_ahead": {"type": "number", "description": "How many days ahead to look", "default": 3}
            }
        }
    }
}

NEWS_TOOL = {
    "type": "function",
    "function": {
        "name": "get_news",
        "description": "Get latest news on specific topics",
        "parameters": {
            "type": "object",
            "properties": {
                "topic": {"type": "string", "description": "News topic"},
                "language": {"type": "string", "description": "Language (de, en)", "default": "de"}
            },
            "required": ["topic"]
        }
    }
}

def get_tools(tool_names: List[str]) -> List[Dict]:
    tool_map = {
        "weather_api": WEATHER_TOOL,
        "web_search": WEB_SEARCH_TOOL,
        "geocoding": GEOCODING_TOOL,
        "tracker_data": TRACKER_DATA_TOOL,
        "food_database": FOOD_DATABASE_TOOL,
        "events": EVENTS_TOOL,
        "maps": MAPS_TOOL,
        "calendar": CALENDAR_TOOL,
        "news": NEWS_TOOL,
    }
    return [tool_map[name] for name in tool_names if name in tool_map]