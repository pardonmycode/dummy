from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter()

# Mock dashboards
dashboards = {
    "default": {
        "id": "default",
        "name": "Standard",
        "widgets": [
            {"id": "w1", "type": "weather", "config": {"location": "Berlin"}, "size": "medium"},
            {"id": "w2", "type": "protein_tracker", "config": {"goal": 150}, "size": "medium"}
        ]
    }
}

class DashboardCreate(BaseModel):
    name: str

class DashboardUpdate(BaseModel):
    name: Optional[str] = None
    widgets: Optional[List[dict]] = None

@router.get("/")
async def list_dashboards():
    return {"dashboards": list(dashboards.values())}

@router.get("/{dashboard_id}")
async def get_dashboard(dashboard_id: str):
    if dashboard_id not in dashboards:
        raise HTTPException(status_code=404, detail="Dashboard not found")
    return dashboards[dashboard_id]

@router.post("/")
async def create_dashboard(request: DashboardCreate):
    new_id = f"dashboard_{len(dashboards) + 1}"
    dashboards[new_id] = {
        "id": new_id,
        "name": request.name,
        "widgets": []
    }
    return {"id": new_id, "message": "Dashboard created"}

@router.put("/{dashboard_id}")
async def update_dashboard(dashboard_id: str, request: DashboardUpdate):
    if dashboard_id not in dashboards:
        raise HTTPException(status_code=404, detail="Dashboard not found")
    if request.name:
        dashboards[dashboard_id]["name"] = request.name
    if request.widgets:
        dashboards[dashboard_id]["widgets"] = request.widgets
    return {"message": "Dashboard updated"}

@router.delete("/{dashboard_id}")
async def delete_dashboard(dashboard_id: str):
    if dashboard_id not in dashboards:
        raise HTTPException(status_code=404, detail="Dashboard not found")
    del dashboards[dashboard_id]
    return {"message": "Dashboard deleted"}
