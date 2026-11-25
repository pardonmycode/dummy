from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from fastapi.responses import StreamingResponse
from typing import Optional
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.models import WidgetInstance, get_db
from app.auth import get_current_user
from app.ai.pipeline import run_widget_pipeline
import json
import asyncio

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

@router.get("/{widget_id}/data/stream")
async def stream_widget_data(widget_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Stream widget data with SSE."""
    async def generate():
        yield f"data: {json.dumps({'status': 'starting', 'widget_id': widget_id})}\n\n"
        
        try:
            data = await run_widget_pipeline(widget_id, {"user_id": user.id}, location="Berlin")
            
            # Store data
            widget = db.query(WidgetInstance).filter(
                WidgetInstance.user_id == user.id,
                WidgetInstance.widget_type == widget_id
            ).first()
            if not widget:
                widget = WidgetInstance(user_id=user.id, widget_type=widget_id, data=data)
                db.add(widget)
            else:
                widget.data = data
            db.commit()
            
            yield f"data: {json.dumps({'status': 'complete', 'data': data})}\n\n"
        except Exception as e:
            yield f"data: {json.dumps({'status': 'error', 'error': str(e)})}\n\n"
    
    return StreamingResponse(generate(), media_type="text/event-stream")

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
        widget_id
    )
    return {"status": "refreshing", "widget_id": widget_id}

async def refresh_widget_task(user_id: int, widget_id: str):
    """Background task to refresh widget data."""
    db = get_db().__next__()
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
    finally:
        db.close()

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