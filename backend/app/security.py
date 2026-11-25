import os
import secrets
from typing import Dict, Any
from cryptography.fernet import Fernet

_KEY_FILE = os.path.expanduser("~/.widgetly/encryption.key")

def _get_or_create_key() -> bytes:
    """Load persistent encryption key from env or key file; create file if needed."""
    key = os.getenv("ENCRYPTION_KEY")
    if key:
        # Validate base64 Fernet key length
        try:
            Fernet(key.encode())
            return key.encode()
        except Exception:
            raise ValueError("ENCRYPTION_KEY env var is not a valid Fernet key")
    if os.path.exists(_KEY_FILE):
        with open(_KEY_FILE, "r") as f:
            key = f.read().strip()
        Fernet(key.encode())  # validate
        return key.encode()
    # Generate, validate, and persist
    key = Fernet.generate_key().decode()
    os.makedirs(os.path.dirname(_KEY_FILE), exist_ok=True)
    with open(_KEY_FILE, "w") as f:
        f.write(key)
    os.chmod(_KEY_FILE, 0o600)
    return key.encode()

ENCRYPTION_KEY = _get_or_create_key()
_cipher = Fernet(ENCRYPTION_KEY)

def encrypt_data(data: Dict) -> str:
    """Encrypt sensitive health data with Fernet (AES-CBC + HMAC)."""
    import json
    plaintext = json.dumps(data).encode()
    return _cipher.encrypt(plaintext).decode()

def decrypt_data(token: str) -> Dict:
    """Decrypt previously encrypted data."""
    import json
    plaintext = _cipher.decrypt(token.encode())
    return json.loads(plaintext.decode())

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
    import re
    text = re.sub(r'\[.*?\]', '', text)
    text = re.sub(r'\\n', '', text)
    return text.strip()

def validate_location_precision(coords: Dict) -> Dict:
    """Ensure location data is not too precise (privacy)."""
    if "lat" in coords and "lon" in coords:
        return {
            "lat": round(coords["lat"], 2),
            "lon": round(coords["lon"], 2)
        }
    return coords