import json
import hashlib
import time
from collections import OrderedDict
from typing import Dict, List, Any, Optional
from dataclasses import dataclass

# Simple in-memory cache with max 500 entries
cache: OrderedDict[str, Any] = OrderedDict()
MAX_CACHE_SIZE = 500

# Request batching: track in-flight requests for deduplication
pending_requests: Dict[str, Any] = {}

def get_shared_cache_key(widget_id: str, location: Optional[str] = None) -> str:
    """Generate a shared cache key (no user_id) for location-based widgets."""
    params = {"widget_id": widget_id}
    if location:
        params["location"] = location.lower().strip()
    params_str = json.dumps(params, sort_keys=True)
    return f"shared:{hashlib.md5(params_str.encode()).hexdigest()}"

def get_cache_key(widget_id: str, params: Dict) -> str:
    """Generate cache key from widget ID and parameters."""
    params_str = json.dumps(params, sort_keys=True)
    return f"{widget_id}:{hashlib.md5(params_str.encode()).hexdigest()}"

def get_cached(widget_id: str, params: Dict) -> Optional[Dict]:
    """Get cached data if not expired."""
    # First check shared cache (location-based, no user_id)
    location = params.get("location")
    shared_key = get_shared_cache_key(widget_id, location)
    if shared_key in cache:
        entry = cache[shared_key]
        if time.time() < entry["expires"]:
            return entry["data"]
    
    # Then check user-specific cache
    key = get_cache_key(widget_id, params)
    if key in cache:
        entry = cache[key]
        if time.time() < entry["expires"]:
            return entry["data"]
    return None

def set_cached(widget_id: str, params: Dict, data: Dict, ttl: int = 300):
    """Cache data with TTL. Also stores in shared cache for location-based deduplication."""
    # Store in user-specific cache
    key = get_cache_key(widget_id, params)
    cache[key] = {
        "data": data,
        "expires": time.time() + ttl,
        "created": time.time()
    }
    
    # Also store in shared cache (for other users with same location)
    location = params.get("location")
    shared_key = get_shared_cache_key(widget_id, location)
    if shared_key != key:
        cache[shared_key] = {
            "data": data,
            "expires": time.time() + ttl,
            "created": time.time()
        }
    
    # Evict oldest entries if over max size
    while len(cache) > MAX_CACHE_SIZE:
        cache.popitem(last=False)

def register_pending_request(widget_id: str, location: Optional[str], request_id: str):
    """Register an in-flight request for deduplication."""
    key = get_shared_cache_key(widget_id, location)
    pending_requests[key] = {
        "request_id": request_id,
        "registered_at": time.time()
    }

def get_pending_request(widget_id: str, location: Optional[str]) -> Optional[str]:
    """Check if another request for same widget/location is already in-flight."""
    key = get_shared_cache_key(widget_id, location)
    if key in pending_requests:
        entry = pending_requests[key]
        if time.time() - entry["registered_at"] < 5:  # Within 5 seconds
            return entry["request_id"]
    return None

def complete_pending_request(widget_id: str, location: Optional[str]):
    """Mark an in-flight request as complete."""
    key = get_shared_cache_key(widget_id, location)
    if key in pending_requests:
        del pending_requests[key]

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
    return {"total": len(cache), "active": active, "expired": expired, "max_size": MAX_CACHE_SIZE}