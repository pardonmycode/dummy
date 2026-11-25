"""Tests for AI validation functions."""
import pytest
from app.ai.validation import (
    validate_widget_data,
    repair_json,
    has_sources,
    WIDGET_SCHEMAS,
)


class TestWidgetValidation:
    """Tests for widget data validation against schemas."""

    def test_valid_weather_data(self):
        """Valid weather data should pass validation."""
        data = {
            "location": "San Francisco, CA",
            "current": {"temperature": 65, "condition": "Partly cloudy"},
            "sources": [{"name": "OpenWeatherMap"}]
        }
        result = validate_widget_data("weather_summary", data)
        assert result["valid"] is True

    def test_missing_required_field(self):
        """Data missing required fields should fail validation."""
        data = {"location": "San Francisco, CA"}
        result = validate_widget_data("weather_summary", data)
        assert result["valid"] is False
        assert any("current" in error for error in result["errors"])

    def test_non_dict_data(self):
        """Non-dict data should fail validation."""
        result = validate_widget_data("weather_summary", "not a dict")
        assert result["valid"] is False

    def test_unknown_widget_id(self):
        """Unknown widget ID should pass validation (no schema)."""
        data = {"anything": "goes"}
        result = validate_widget_data("unknown_widget", data)
        assert result["valid"] is True

    def test_party_events_validation(self):
        """Party events should validate against schema."""
        data = {
            "events": [
                {
                    "name": "Tech Meetup",
                    "location": "Downtown SF",
                    "start": "2025-01-15T18:00:00Z"
                }
            ],
            "sources": [{"name": "Eventbrite"}]
        }
        result = validate_widget_data("party_recommendations", data)
        assert result["valid"] is True


class TestJSONRepair:
    """Tests for JSON repair functionality."""

    def test_valid_json(self):
        """Valid JSON should parse correctly."""
        json_str = '{"name": "test", "value": 42}'
        result = repair_json(json_str)
        assert result is not None
        assert result["name"] == "test"
        assert result["value"] == 42

    def test_trailing_comma_object(self):
        """JSON with trailing comma in object should be repaired."""
        json_str = '{"name": "test", "value": 42,}'
        result = repair_json(json_str)
        assert result is not None
        assert result["name"] == "test"

    def test_trailing_comma_array(self):
        """JSON with trailing comma in array should be repaired."""
        json_str = '{"items": [1, 2, 3,]}'
        result = repair_json(json_str)
        assert result is not None
        assert len(result["items"]) == 3

    def test_whitespace_handling(self):
        """JSON with extra whitespace should be parsed."""
        json_str = '  {"name": "test"}  '
        result = repair_json(json_str)
        assert result is not None
        assert result["name"] == "test"

    def test_unparseable_json_returns_wrapped(self):
        """Unparseable text should be wrapped in a data object as fallback."""
        json_str = 'this is not json at all {{{'
        result = repair_json(json_str)
        # The repair function wraps unparseable text in {"data": "..."}
        assert result is not None
        assert "data" in result
        assert result["data"] == json_str


class TestSourcesValidation:
    """Tests for sources field validation."""

    def test_data_with_sources(self):
        """Data with non-empty sources list should pass."""
        data = {"sources": [{"name": "Source 1"}, {"name": "Source 2"}]}
        assert has_sources(data) is True

    def test_data_without_sources(self):
        """Data without sources should fail."""
        data = {"name": "test"}
        assert has_sources(data) is False

    def test_empty_sources_list(self):
        """Empty sources list should fail."""
        data = {"sources": []}
        assert has_sources(data) is False

    def test_sources_not_a_list(self):
        """Sources that are not a list should fail."""
        data = {"sources": "not a list"}
        assert has_sources(data) is False


class TestWidgetSchemas:
    """Tests for schema definitions."""

    def test_weather_schema_exists(self):
        """Weather summary schema should be defined."""
        assert "weather_summary" in WIDGET_SCHEMAS
        schema = WIDGET_SCHEMAS["weather_summary"]
        assert "required" in schema
        assert "location" in schema["required"]

    def test_party_schema_exists(self):
        """Party recommendations schema should be defined."""
        assert "party_recommendations" in WIDGET_SCHEMAS
        schema = WIDGET_SCHEMAS["party_recommendations"]
        assert "events" in schema["required"]