from fastapi import APIRouter, HTTPException, BackgroundTasks
from typing import Optional
from pydantic import BaseModel

router = APIRouter()

# In-memory storage for demo
widget_data = {
    "weather": {
        "schemaVersion": 1,
        "data": {
            "location": "Berlin",
            "current": {
                "temperature": 22,
                "feelsLike": 23,
                "condition": "Sonnig",
                "humidity": 45,
                "windSpeed": 12,
            },
            "hourly": [
                {"time": "Jetzt", "temp": 22, "condition": "Sonnig"},
                {"time": "14:00", "temp": 24, "condition": "Sonnig"},
                {"time": "15:00", "temp": 23, "condition": "Wolken"},
            ],
            "daily": [
                {"day": "Mo", "high": 24, "low": 14, "condition": "Sonnig"},
                {"day": "Di", "high": 22, "low": 13, "condition": "Regen"},
            ],
            "summary": "Heute sonnig mit 22°C."
        },
        "sources": ["OpenWeatherMap API"],
        "generatedAt": "2025-11-23T14:00:00Z"
    },
    "protein_tracker": {
        "schemaVersion": 1,
        "data": {
            "goal": 150,
            "consumed": 95,
            "meals": [
                {"name": "Frühstück: Eier & Avocado", "protein": 25, "time": "08:00"},
                {"name": "Mittag: Hähnchen & Reis", "protein": 40, "time": "12:30"},
            ]
        },
        "sources": ["Lokale Einträge"],
        "generatedAt": "2025-11-23T14:00:00Z"
    }
}

class RefreshRequest(BaseModel):
    force: Optional[bool] = False

class ActionRequest(BaseModel):
    action: str
    data: Optional[dict] = None

@router.get("/{widget_id}/data")
async def get_widget_data(widget_id: str):
    if widget_id not in widget_data:
        raise HTTPException(status_code=404, detail=f"Widget '{widget_id}' not found")
    return widget_data[widget_id]

@router.post("/{widget_id}/refresh")
async def refresh_widget(widget_id: str, request: RefreshRequest, background_tasks: BackgroundTasks):
    if widget_id not in widget_data:
        raise HTTPException(status_code=404, detail=f"Widget '{widget_id}' not found")
    # In a real implementation, this would trigger the AI pipeline
    return {"status": "refreshing", "widget_id": widget_id}

@router.post("/{widget_id}/action")
async def widget_action(widget_id: str, request: ActionRequest):
    if widget_id not in widget_data:
        raise HTTPException(status_code=404, detail=f"Widget '{widget_id}' not found")
    return {"status": "action_received", "widget_id": widget_id, "action": request.action}

@router.get("/available")
async def list_available_widgets():
    return {"widgets": list(widget_data.keys())}
