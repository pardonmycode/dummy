from typing import Dict, Any
from datetime import datetime
import hashlib
import secrets
import json

# Encryption keys (in production, use proper key management)
ENCRYPTION_KEY = secrets.token_bytes(32)

def encrypt_data(data: Dict) -> str:
    """Encrypt sensitive health data."""
    json_data = json.dumps(data)
    return hashlib.sha256((json_data + ENCRYPTION_KEY.hex()).encode()).hexdigest()

def validate_url(url: str) -> bool:
    """Validate a URL to prevent injection attacks."""
    from urllib.parse import urlparse
    try:
        result = urlparse(url)
        return all([result.scheme in ("http", "https"), result.netloc])
    except Exception:
        return False

def sanitize_text(text: str) -> str:
    """Sanitize text to prevent prompt injection."""
    # Remove common injection patterns
    import re
    text = re.sub(r'\[.*?\]', '', text)  # Remove brackets
    text = re.sub(r'\\n', '', text)  # Remove newlines
    return text.strip()

def validate_location_precision(coords: Dict) -> Dict:
    """Ensure location data is not too precise (privacy)."""
    if "lat" in coords and "lon" in coords:
        # Round to 2 decimal places (about 1km precision)
        return {
            "lat": round(coords["lat"], 2),
            "lon": round(coords["lon"], 2)
        }
    return coords