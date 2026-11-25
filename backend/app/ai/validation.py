import json
from typing import Dict, Any, Optional

# Widget schema definitions
WIDGET_SCHEMAS: Dict[str, Dict] = {
    "weather_summary": {
        "type": "object",
        "required": ["location", "current", "sources"],
        "properties": {
            "location": {"type": "string"},
            "current": {
                "type": "object",
                "required": ["temperature", "condition"],
                "properties": {
                    "temperature": {"type": "number"},
                    "feelsLike": {"type": "number"},
                    "condition": {"type": "string"},
                    "humidity": {"type": "number"},
                    "windSpeed": {"type": "number"}
                }
            },
            "sources": {"type": "array"}
        }
    },
    "party_recommendations": {
        "type": "object",
        "required": ["events", "sources"],
        "properties": {
            "events": {
                "type": "array",
                "items": {
                    "type": "object",
                    "required": ["name", "location", "start"],
                    "properties": {
                        "name": {"type": "string"},
                        "location": {"type": "string"},
                        "coordinates": {"type": "object"},
                        "start": {"type": "string"},
                        "end": {"type": "string"},
                        "genre": {"type": "string"},
                        "price": {"type": "string"},
                        "link": {"type": "string"},
                        "source": {"type": "string"},
                        "confidence": {"type": "number"}
                    }
                }
            },
            "sources": {"type": "array"}
        }
    }
}

def validate_widget_data(widget_id: str, data: Any) -> Dict:
    """Validate widget data against its schema."""
    try:
        if not isinstance(data, dict):
            return {"valid": False, "errors": ["Data must be a JSON object"]}
        
        schema = WIDGET_SCHEMAS.get(widget_id)
        if not schema:
            return {"valid": True, "errors": []}
        
        errors = []
        required_fields = schema.get("required", [])
        for field in required_fields:
            if field not in data:
                errors.append(f"Missing required field: {field}")
        
        return {"valid": len(errors) == 0, "errors": errors}
    except Exception as e:
        return {"valid": False, "errors": [str(e)]}

def repair_json(text: str) -> Optional[Dict]:
    """Try to repair malformed JSON."""
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        # Try to fix common issues
        fixed = text.strip()
        # Remove trailing commas
        import re
        fixed = re.sub(r',\s*}', '}', fixed)
        fixed = re.sub(r',\s*]', ']', fixed)
        try:
            return json.loads(fixed)
        except json.JSONDecodeError:
            # Try wrapping in quotes for string values
            try:
                return json.loads('{"data": "' + fixed.replace('"', '\\"') + '"}')
            except:
                return None

def has_sources(data: Dict) -> bool:
    """Check if data has required sources field."""
    return isinstance(data.get("sources"), list) and len(data["sources"]) > 0

import re

# Patterns indicating factual data that requires sourcing
FACTUAL_PATTERNS = [
    r'\d{1,2}\.\s+\d{1,2}\.',          # German date format (DD. MM.)
    r'\d{4}-\d{2}-\d{2}',              # ISO date
    r'\d{1,2}[:.]?\d{2}\s*(Uhr|h)',    # Time expressions
    r'\d+,\d+\s*°C',                    # Temperature
    r'\d+\s*(€|EUR|DM)',               # Prices in EUR
    r'https?://\S+',                    # URLs
    r'[-+]?[0-9]*\.?[0-9]+%?',          # Percentages/numbers
]

def contains_factual_data(text: str) -> bool:
    """Check if text contains factual data (dates, times, prices, locations, links)."""
    if not isinstance(text, str):
        return False
    for pattern in FACTUAL_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    return False

def validate_quellenpflicht(widget_id: str, result: Dict) -> Dict:
    """
    Enforce Quellenpflicht: check that factual data includes sources.
    
    Returns validation result with 'valid' and 'errors' keys.
    """
    errors = []
    content = result.get("content", "")
    sources = result.get("sources", [])
    
    if contains_factual_data(content):
        if not has_sources(result):
            errors.append("Faktische Daten enthalten, aber keine Quellen angegeben")
        elif not isinstance(sources, list) or len(sources) == 0:
            errors.append("Quellen-Pflicht verletzt: sources-Feld ist leer")
    
    return {"valid": len(errors) == 0, "errors": errors}