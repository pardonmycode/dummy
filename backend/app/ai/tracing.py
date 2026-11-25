import json
import time
from datetime import datetime
from typing import Dict, List, Any, Optional

traces: List[Dict] = []

def start_trace(user_id: int, widget_id: str, prompt: Optional[str] = None) -> str:
    """Start a new AI run trace."""
    trace_id = f"trace_{int(time.time() * 1000)}"
    trace = {
        "id": trace_id,
        "user_id": user_id,
        "widget_id": widget_id,
        "prompt": prompt,
        "started_at": datetime.utcnow().isoformat(),
        "steps": [],
        "completed": False
    }
    traces.append(trace)
    return trace_id

def add_trace_step(trace_id: str, step: str, data: Dict):
    """Add a step to an existing trace."""
    for trace in traces:
        if trace["id"] == trace_id:
            trace["steps"].append({
                "step": step,
                "data": data,
                "timestamp": datetime.utcnow().isoformat()
            })
            break

def complete_trace(trace_id: str, tokens_used: int, response: Optional[str] = None):
    """Mark a trace as completed."""
    for trace in traces:
        if trace["id"] == trace_id:
            trace["completed"] = True
            trace["tokens_used"] = tokens_used
            trace["response"] = response
            trace["completed_at"] = datetime.utcnow().isoformat()
            break

def get_traces(widget_id: Optional[str] = None, user_id: Optional[int] = None, limit: int = 10) -> List[Dict]:
    """Get recent traces."""
    filtered = traces
    if widget_id:
        filtered = [t for t in filtered if t["widget_id"] == widget_id]
    if user_id:
        filtered = [t for t in filtered if t["user_id"] == user_id]
    
    # Return most recent, strip sensitive data
    return [{
        "id": t["id"],
        "widget_id": t["widget_id"],
        "user_id": t["user_id"],
        "started_at": t["started_at"],
        "completed_at": t.get("completed_at"),
        "tokens_used": t.get("tokens_used"),
        "step_count": len(t["steps"])
    } for t in filtered[-limit:]][::-1]