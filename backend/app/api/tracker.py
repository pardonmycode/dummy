from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

from app.auth import get_current_user
from app.models import User

router = APIRouter()

# Mock tracker data (per-user would require DB)
tracker_entries = {
    "protein": [],
    "carbs": [],
    "water": []
}

class TrackerEntry(BaseModel):
    value: float
    unit: str
    timestamp: Optional[datetime] = None
    note: Optional[str] = None
    meal_name: Optional[str] = None

@router.get("/{tracker_type}/entries")
async def get_entries(tracker_type: str, current_user: User = Depends(get_current_user)):
    if tracker_type not in tracker_entries:
        raise HTTPException(status_code=404, detail="Tracker type not found")
    return {"entries": tracker_entries[tracker_type]}

@router.get("/{tracker_type}/summary")
async def get_summary(tracker_type: str, current_user: User = Depends(get_current_user)):
    if tracker_type not in tracker_entries:
        raise HTTPException(status_code=404, detail="Tracker type not found")
    entries = tracker_entries[tracker_type]
    total = sum(e["value"] for e in entries)
    return {"total": total, "count": len(entries)}

@router.post("/{tracker_type}/entries")
async def add_entry(tracker_type: str, entry: TrackerEntry, current_user: User = Depends(get_current_user)):
    if tracker_type not in tracker_entries:
        raise HTTPException(status_code=404, detail="Tracker type not found")
    entry_dict = entry.model_dump()
    entry_dict["id"] = f"e_{len(tracker_entries[tracker_type]) + 1}"
    entry_dict["timestamp"] = datetime.now().isoformat()
    entry_dict["user_id"] = current_user.id
    tracker_entries[tracker_type].append(entry_dict)
    return {"id": entry_dict["id"], "message": "Entry added"}

@router.delete("/{tracker_type}/entries/{entry_id}")
async def delete_entry(tracker_type: str, entry_id: str, current_user: User = Depends(get_current_user)):
    if tracker_type not in tracker_entries:
        raise HTTPException(status_code=404, detail="Tracker type not found")
    entries = tracker_entries[tracker_type]
    for i, e in enumerate(entries):
        if e["id"] == entry_id and e.get("user_id") == current_user.id:
            entries.pop(i)
            return {"message": "Entry deleted"}
    raise HTTPException(status_code=404, detail="Entry not found")

@router.get("/{tracker_type}/goals")
async def get_goals(tracker_type: str, current_user: User = Depends(get_current_user)):
    # Mock goals
    goals = {
        "protein": {"daily": 150, "unit": "g"},
        "carbs": {"daily": 300, "unit": "g"},
        "water": {"daily": 2000, "unit": "ml"}
    }
    if tracker_type not in goals:
        raise HTTPException(status_code=404, detail="Goals not found")
    return goals[tracker_type]
