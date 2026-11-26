"""Tests for AI tool implementations."""
import pytest
import asyncio
from unittest.mock import patch, AsyncMock, MagicMock
import json


@pytest.mark.asyncio
async def test_web_search_valid():
    """Test web search with mock HTTP response."""
    from app.ai.tools import web_search, _parse_ddg_results

    # Test the parser directly with sample HTML
    html = '''
    <a class="result__a" href="https://example.com/page">Example Title</a>
    <div class="result__snippet">Example snippet text here.</div>
    <a class="result__a" href="https://example2.com/page">Second Title</a>
    <div class="result__snippet">Second snippet.</div>
    '''
    results = _parse_ddg_results(html, 5)
    assert len(results) == 2
    assert results[0]["title"] == "Example Title"
    assert results[0]["url"] == "https://example.com/page"
    assert "Example snippet" in results[0]["snippet"]


@pytest.mark.asyncio
async def test_web_search_empty_query():
    """Test web search with empty query."""
    from app.ai.tools import web_search
    result = await web_search("")
    assert "error" in result
    assert result["results"] == []


@pytest.mark.asyncio
async def test_geocode_valid():
    """Test geocoding with mock response."""
    from app.ai.tools import geocode

    mock_response = MagicMock()
    mock_response.json.return_value = [{
        "lat": "52.5200",
        "lon": "13.4050",
        "display_name": "Berlin, Germany",
        "type": "city",
        "class": "place"
    }]
    mock_response.raise_for_status = MagicMock()

    with patch("app.ai.tools.httpx.AsyncClient") as MockClient:
        client_instance = AsyncMock()
        client_instance.get.return_value = mock_response
        MockClient.return_value.__aenter__.return_value = client_instance

        result = await geocode("Berlin, Germany")
        assert result["lat"] == 52.52
        assert result["lon"] == 13.405
        assert "Berlin" in result["display_name"]
        assert "error" not in result


@pytest.mark.asyncio
async def test_geocode_empty_address():
    """Test geocoding with empty address."""
    from app.ai.tools import geocode
    result = await geocode("")
    assert "error" in result
    assert result["lat"] is None


@pytest.mark.asyncio
async def test_geocode_no_results():
    """Test geocoding with no results."""
    from app.ai.tools import geocode

    mock_response = MagicMock()
    mock_response.json.return_value = []
    mock_response.raise_for_status = MagicMock()

    with patch("app.ai.tools.httpx.AsyncClient") as MockClient:
        client_instance = AsyncMock()
        client_instance.get.return_value = mock_response
        MockClient.return_value.__aenter__.return_value = client_instance

        result = await geocode("nonexistent place xyz")
        assert "error" in result or "No results" in result.get("error", "")


@pytest.mark.asyncio
async def test_get_route_valid():
    """Test routing with mocked geocoding and OSRM."""
    from app.ai.tools import get_route, _format_duration

    # Test duration formatting
    assert _format_duration(45) == "45s"
    assert _format_duration(1500) == "25 min"
    assert _format_duration(3720) == "1h 2 min"

    # Mock both geocode calls and OSRM
    with patch("app.ai.tools.geocode") as mock_geocode, \
         patch("app.ai.tools.httpx.AsyncClient") as MockClient:

        mock_geocode.side_effect = [
            {"lat": 52.52, "lon": 13.405, "error": None},
            {"lat": 48.8566, "lon": 2.3522, "error": None}
        ]

        mock_osrm_response = MagicMock()
        mock_osrm_response.json.return_value = {
            "code": "Ok",
            "routes": [{
                "distance": 878000,
                "duration": 29500,
                "geometry": "polyline_data",
                "legs": [{"steps": [{"distance": 100}, {"distance": 200}]}]
            }]
        }
        mock_osrm_response.raise_for_status = MagicMock()

        client_instance = AsyncMock()
        client_instance.get.return_value = mock_osrm_response
        MockClient.return_value.__aenter__.return_value = client_instance

        result = await get_route("Berlin, Germany", "Paris, France", "car")
        assert "error" not in result
        assert result["distance_meters"] == 878000
        assert result["duration_seconds"] == 29500
        assert result["mode"] == "car"
        assert "8h 11 min" in result["duration_formatted"]


@pytest.mark.asyncio
async def test_get_route_missing_addresses():
    """Test routing with missing addresses."""
    from app.ai.tools import get_route
    result = await get_route("", "Paris")
    assert "error" in result


@pytest.mark.asyncio
async def test_search_events_valid():
    """Test event search with mock web search."""
    from app.ai.tools import search_events

    mock_search_result = {
        "query": "events party Berlin",
        "results": [
            {"title": "Club Night Berlin", "url": "https://example.com/1", "snippet": "DJ party tonight"},
            {"title": "Concert at Tempelhofer", "url": "https://example.com/2", "snippet": "Live music"}
        ],
        "sources": ["DuckDuckGo search: events party Berlin"]
    }

    with patch("app.ai.tools.web_search", return_value=mock_search_result) as mock_search:
        result = await search_events("Berlin", event_type="party")
        assert "error" not in result
        assert result["city"] == "Berlin"
        assert result["type"] == "party"
        assert len(result["events"]) == 2
        assert result["events"][0]["title"] == "Club Night Berlin"
        mock_search.assert_called_once()


@pytest.mark.asyncio
async def test_search_events_empty_city():
    """Test event search with empty city."""
    from app.ai.tools import search_events
    result = await search_events("")
    assert "error" in result


@pytest.mark.asyncio
async def test_rate_limiter():
    """Test rate limiter basic functionality."""
    from app.ai.tools import _rate_limit, _request_times

    # Clear previous times
    _request_times.clear()

    # First request should not wait
    start = asyncio.get_event_loop().time()
    await _rate_limit("test_service", 10.0)
    elapsed = asyncio.get_event_loop().time() - start
    assert elapsed < 0.5, "First request should not be rate limited"


def test_get_tools():
    """Test tool selection."""
    from app.ai.tools import get_tools
    tools = get_tools(["web_search", "geocoding", "maps"])
    assert len(tools) == 3
    assert tools[0]["function"]["name"] == "web_search"
    assert tools[1]["function"]["name"] == "geocode"
    assert tools[2]["function"]["name"] == "get_route"
