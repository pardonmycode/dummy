"""
AI Tool Definitions and Implementations

Defines tool schemas for the LLM and implements real API-backed
executions for web search, geocoding, routing, and event search.

Rate Limiting Considerations:
- Nominatim: 1 req/sec, use User-Agent header (required by their TOS)
- OSRM: No official rate limit, but be reasonable (<10 req/sec)
- DuckDuckGo: No official API, use sparingly (<1 req/sec)
- Eventbrite: Public search has rate limits, use sparingly
"""
import asyncio
import json
import logging
import time
from typing import Dict, List, Any, Optional

import httpx

logger = logging.getLogger(__name__)

# User-Agent for Nominatim (required by their Terms of Service)
NOMINATIM_USER_AGENT = "widgetly-app/1.0 (https://widgetly.app)"
OSRM_USER_AGENT = "widgetly-app/1.0"

# Rate limiter: track request times per service
_request_times: Dict[str, List[float]] = {}


async def _rate_limit(service: str, max_per_second: float) -> None:
    """Simple async rate limiter using time-based spacing."""
    now = time.time()
    if service not in _request_times:
        _request_times[service] = []

    # Remove old entries (> 1 second)
    _request_times[service] = [t for t in _request_times[service] if now - t < 1.0]

    # If at limit, wait
    if len(_request_times[service]) >= max_per_second:
        oldest = _request_times[service][0]
        wait_time = 1.0 - (now - oldest)
        if wait_time > 0:
            await asyncio.sleep(wait_time)
            now = time.time()

    _request_times[service].append(now)


# =============================================================================
# Tool Definitions (schemas for the LLM)
# =============================================================================

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
        "description": "Search the web for information using DuckDuckGo",
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
        "description": "Get coordinates for an address or location using OpenStreetMap Nominatim",
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
        "description": "Get route and travel time between two points using OSRM",
        "parameters": {
            "type": "object",
            "properties": {
                "from": {"type": "string", "description": "Starting point (address or location name)"},
                "to": {"type": "string", "description": "Destination (address or location name)"},
                "mode": {"type": "string", "description": "Travel mode (car, walk, bike)", "default": "car"}
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
    """Get tool definitions by name."""
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


# =============================================================================
# Tool Implementations
# =============================================================================

async def web_search(query: str, limit: int = 5) -> Dict:
    """
    Search the web using DuckDuckGo's HTML API.

    Rate limiting: ~1 req/sec recommended (no official API).
    Returns: List of results with title, url, snippet.
    """
    if not query or not query.strip():
        return {"error": "Empty search query", "results": []}

    try:
        await _rate_limit("duckduckgo", 1.0)

        url = "https://html.duckduckgo.com/html/"
        params = {"q": query, "kl": "de-de"}
        headers = {
            "User-Agent": "Mozilla/5.0 (compatible; Widgetly/1.0; +https://widgetly.app)",
            "Accept-Language": "de-DE,de;q=0.9,en;q=0.8",
        }

        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.get(url, params=params, headers=headers)
            response.raise_for_status()

        # Parse HTML results
        results = _parse_ddg_results(response.text, limit)
        return {
            "query": query,
            "results": results,
            "sources": [f"DuckDuckGo search: {query}"]
        }

    except httpx.TimeoutException:
        logger.warning(f"DuckDuckGo search timed out for: {query}")
        return {"error": "Search timed out", "results": []}
    except httpx.HTTPError as e:
        logger.error(f"DuckDuckGo search failed: {e}")
        return {"error": f"Search failed: {e}", "results": []}


def _parse_ddg_results(html: str, limit: int = 5) -> List[Dict]:
    """Parse DuckDuckGo HTML search results."""
    import re
    import html as html_module

    results = []
    # DuckDuckGo results are in .result-links divs with specific structure
    # Each result has a link with class "result__a"
    pattern = re.compile(
        r'<a[^>]*class="[^"]*result__a[^"]*"[^>]*href="([^"]*)"[^>]*>([^<]*)</a>'
        r'[^<]*'
        r'<div[^>]*class="[^"]*result__snippet[^"]*"[^>]*>(.*?)</div>',
        re.DOTALL | re.IGNORECASE
    )

    for match in pattern.finditer(html):
        if len(results) >= limit:
            break

        url = match.group(1)
        title = html_module.unescape(match.group(2).strip())
        snippet = html_module.unescape(re.sub(r'<[^>]+>', '', match.group(3)).strip())

        # Clean up URL
        if url.startswith('/'):
            url = 'https://duckduckgo.com' + url

        results.append({
            "title": title,
            "url": url,
            "snippet": snippet[:200]
        })

    # Fallback: if regex parsing didn't work, try simpler approach
    if not results:
        link_pattern = re.compile(r'<a[^>]*href="(https?://[^"]+)"[^>]*>([^<]+)</a>')
        for match in link_pattern.finditer(html):
            if len(results) >= limit:
                break
            url, title = match.groups()
            if url.startswith('https://duckduckgo.com'):
                continue
            results.append({"title": html_module.unescape(title), "url": url, "snippet": ""})

    return results


async def geocode(address: str) -> Dict:
    """
    Geocode an address using OpenStreetMap Nominatim.

    Rate limiting: 1 req/sec (required by Nominatim TOS).
    Returns: lat, lon, display_name, and other location details.
    """
    if not address or not address.strip():
        return {"error": "Empty address", "lat": None, "lon": None}

    try:
        await _rate_limit("nominatim", 1.0)

        url = "https://nominatim.openstreetmap.org/search"
        params = {
            "q": address,
            "format": "json",
            "limit": 1,
            "addressdetails": 1,
            "accept-language": "de,en"
        }
        headers = {
            "User-Agent": NOMINATIM_USER_AGENT,
            "Accept": "application/json",
        }

        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.get(url, params=params, headers=headers)
            response.raise_for_status()

        data = response.json()

        if not data:
            return {
                "error": f"No results for: {address}",
                "lat": None,
                "lon": None,
                "address": address
            }

        result = data[0]
        return {
            "lat": float(result.get("lat", 0)),
            "lon": float(result.get("lon", 0)),
            "display_name": result.get("display_name", ""),
            "address": address,
            "type": result.get("type", ""),
            "class": result.get("class", ""),
            "sources": [f"Nominatim geocoding: {address}"]
        }

    except httpx.TimeoutException:
        logger.warning(f"Nominatim geocoding timed out for: {address}")
        return {"error": "Geocoding timed out", "lat": None, "lon": None}
    except httpx.HTTPError as e:
        logger.error(f"Nominatim geocoding failed: {e}")
        return {"error": f"Geocoding failed: {e}", "lat": None, "lon": None}


async def get_route(from_addr: str, to_addr: str, mode: str = "car") -> Dict:
    """
    Get route and travel time using OSRM (Open Source Routing Machine).

    Rate limiting: No official limit, but keep under 10 req/sec.
    Modes: car (driving), walk (foot), bike (cycling).
    Returns: distance (meters), duration (seconds), route coordinates.
    """
    if not from_addr or not to_addr:
        return {"error": "Missing start or end address"}

    # Geocode both points first
    from_loc = await geocode(from_addr)
    if from_loc.get("error") or from_loc.get("lat") is None:
        return {
            "error": f"Could not geocode start: {from_addr}",
            "details": from_loc.get("error")
        }

    to_loc = await geocode(to_addr)
    if to_loc.get("error") or to_loc.get("lat") is None:
        return {
            "error": f"Could not geocode destination: {to_addr}",
            "details": to_loc.get("error")
        }

    # OSRM routing
    try:
        await _rate_limit("osrm", 10.0)

        # Map mode to OSRM profile
        profile_map = {
            "car": "driving",
            "walk": "foot",
            "bike": "cycling"
        }
        profile = profile_map.get(mode, "driving")

        url = f"https://router.project-osrm.org/route/v1/{profile}"
        coords = (
            f"{from_loc['lon']},{from_loc['lat']}"
            f";{to_loc['lon']},{to_loc['lat']}"
        )
        params = {
            "overview": "true",
            "geometries": "polyline6",
            "steps": "true"
        }

        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.get(url, params=params, headers={"User-Agent": OSRM_USER_AGENT})
            response.raise_for_status()

        data = response.json()

        if data.get("code") != "Ok" or not data.get("routes"):
            return {
                "error": f"OSRM routing failed: {data.get('code', 'unknown')}",
                "from": from_addr,
                "to": to_addr
            }

        route = data["routes"][0]
        return {
            "from": from_addr,
            "to": to_addr,
            "from_coordinates": {"lat": from_loc["lat"], "lon": from_loc["lon"]},
            "to_coordinates": {"lat": to_loc["lat"], "lon": to_loc["lon"]},
            "distance_meters": route.get("distance", 0),
            "duration_seconds": route.get("duration", 0),
            "duration_formatted": _format_duration(route.get("duration", 0)),
            "mode": mode,
            "geometry": route.get("geometry", ""),
            "steps_count": len(route.get("legs", [{}])[0].get("steps", [])),
            "sources": [f"OSRM routing: {from_addr} to {to_addr}"]
        }

    except httpx.TimeoutException:
        logger.warning(f"OSRM routing timed out: {from_addr} to {to_addr}")
        return {"error": "Routing timed out"}
    except httpx.HTTPError as e:
        logger.error(f"OSRM routing failed: {e}")
        return {"error": f"Routing failed: {e}"}


def _format_duration(seconds: float) -> str:
    """Format seconds into human-readable duration."""
    if seconds < 60:
        return f"{int(seconds)}s"
    minutes = int(seconds / 60)
    if minutes < 60:
        return f"{minutes} min"
    hours = int(minutes / 60)
    mins = minutes % 60
    if mins == 0:
        return f"{hours}h"
    return f"{hours}h {mins} min"


async def search_events(city: str, date: Optional[str] = None, event_type: Optional[str] = None) -> Dict:
    """
    Search for events in a city using DuckDuckGo web search.

    Uses web search to find current events (parties, concerts, exhibitions).
    Rate limiting: inherits DuckDuckGo rate limit (~1 req/sec).
    Returns: List of events found via web search.
    """
    if not city or not city.strip():
        return {"error": "Empty city", "events": []}

    # Build search query
    query_parts = ["events"]
    if event_type:
        query_parts.append(event_type)
    query_parts.append(city)
    if date:
        query_parts.append(date)
    query = " ".join(query_parts)

    try:
        # Use web search to find events
        search_results = await web_search(query, limit=8)

        if search_results.get("error"):
            return {
                "error": f"Event search failed: {search_results['error']}",
                "city": city,
                "events": []
            }

        # Process search results into event-like objects
        events = []
        for result in search_results.get("results", []):
            events.append({
                "title": result.get("title", ""),
                "url": result.get("url", ""),
                "description": result.get("snippet", ""),
                "city": city,
                "type": event_type or "unknown"
            })

        return {
            "city": city,
            "date": date,
            "type": event_type,
            "query": query,
            "events": events,
            "count": len(events),
            "sources": search_results.get("sources", [f"Event search: {query}"])
        }

    except Exception as e:
        logger.error(f"Event search failed: {e}")
        return {
            "error": str(e),
            "city": city,
            "events": []
        }
