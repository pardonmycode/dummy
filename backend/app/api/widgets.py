from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from typing import Optional
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.models import WidgetInstance, get_db
from app.auth import get_current_user
from app.ai.pipeline import run_widget_pipeline

router = APIRouter()

class RefreshRequest(BaseModel):
    force: Optional[bool] = False

class ActionRequest(BaseModel):
    action: str
    data: Optional[dict] = None

@router.get("/{widget_id}/data")
async def get_widget_data(widget_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    widget = db.query(WidgetInstance).filter(
        WidgetInstance.user_id == user.id,
        WidgetInstance.widget_type == widget_id
    ).first()
    
    if widget and widget.data:
        return widget.data
    
    # No stored data, run pipeline
    return await run_widget_pipeline(widget_id, {"user_id": user.id}, location="Berlin")

@router.post("/{widget_id}/refresh")
async def refresh_widget(
    widget_id: str,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    background_tasks.add_task(
        refresh_widget_task,
        user.id,
        widget_id,
        db
    )
    return {"status": "refreshing", "widget_id": widget_id}

async def refresh_widget_task(user_id: int, widget_id: str, db):
    """Background task to refresh widget data."""
    try:
        data = await run_widget_pipeline(widget_id, {"user_id": user_id})
        
        widget = db.query(WidgetInstance).filter(
            WidgetInstance.user_id == user_id,
            WidgetInstance.widget_type == widget_id
        ).first()
        
        if widget:
            widget.data = data
            db.commit()
    except Exception as e:
        print(f"Error refreshing widget {widget_id}: {e}")

@router.post("/{widget_id}/action")
async def widget_action(
    widget_id: str,
    request: ActionRequest,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    return {
        "status": "action_received",
        "widget_id": widget_id,
        "action": request.action
    }

@router.get("/available")
async def list_available_widgets(user=Depends(get_current_user)):
    return {
        "widgets": [
            "weather_summary",
            "party_recommendations",
            "health_insights",
            "meal_suggestions",
            "protein_tracker",
            "carbs_tracker",
            "water_tracker",
            "steps_tracker"
        ]
    }