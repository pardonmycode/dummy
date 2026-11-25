import json
import hashlib
import time
from typing import Dict, List, Any, Optional
from dataclasses import dataclass

# Simple in-memory cache
cache: Dict[str, Any] = {}

def get_cache_key(widget_id: str, params: Dict) -> str:
    """Generate cache key from widget ID and parameters."""
    params_str = json.dumps(params, sort_keys=True)
    return f"{widget_id}:{hashlib.md5(params_str.encode()).hexdigest()}"

def get_cached(widget_id: str, params: Dict) -> Optional[Dict]:
    """Get cached data if not expired."""
    key = get_cache_key(widget_id, params)
    if key in cache:
        entry = cache[key]
        if time.time() < entry["expires"]:
            return entry["data"]
    return None

def set_cached(widget_id: str, params: Dict, data: Dict, ttl: int = 300):
    """Cache data with TTL."""
    key = get_cache_key(widget_id, params)
    cache[key] = {
        "data": data,
        "expires": time.time() + ttl,
        "created": time.time()
    }

def clear_cache(widget_id: Optional[str] = None):
    """Clear cache for a widget or all."""
    if widget_id:
        keys_to_remove = [k for k in cache if k.startswith(f"{widget_id}:")]
        for k in keys_to_remove:
            del cache[k]
    else:
        cache.clear()

def get_cache_stats():
    """Get cache statistics."""
    now = time.time()
    active = sum(1 for entry in cache.values() if now < entry["expires"])
    expired = len(cache) - active
    return {"total": len(cache), "active": active, "expired": expired}