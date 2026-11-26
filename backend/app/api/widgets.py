from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from fastapi.responses import StreamingResponse
from typing import Optional
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.models import WidgetInstance, get_db
from app.auth import get_current_user
from app.ai.pipeline import run_widget_pipeline
from app.ai.job_queue import job_queue
from app.scheduler import schedule_widget_refresh
import json
import asyncio

router = APIRouter()

class RefreshRequest(BaseModel):
    force: Optional[bool] = False

class ScheduleRequest(BaseModel):
    interval_minutes: int = 30

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
    """Stream widget data with SSE, sending progress events (loading, processing, complete)."""
    
    # Use a queue to communicate progress events from the pipeline
    event_queue = asyncio.Queue()
    
    async def on_progress(status, data):
        """Callback called by the pipeline with progress updates."""
        await event_queue.put({
            "status": status,
            "widget_id": widget_id,
            "data": data
        })
    
    async def run_pipeline():
        """Run the pipeline and signal completion."""
        try:
            result = await run_widget_pipeline(
                widget_id,
                {"user_id": user.id},
                on_progress=on_progress
            )
            # Store data
            widget = db.query(WidgetInstance).filter(
                WidgetInstance.user_id == user.id,
                WidgetInstance.widget_type == widget_id
            ).first()
            if not widget:
                widget = WidgetInstance(user_id=user.id, widget_type=widget_id, data=result)
                db.add(widget)
            else:
                widget.data = result
            db.commit()
            await event_queue.put({
                "status": "complete",
                "data": result
            })
        except Exception as e:
            await event_queue.put({
                "status": "error",
                "error": str(e)
            })
        finally:
            # Signal that we're done
            await event_queue.put(None)
    
    # Start the pipeline
    pipeline_task = asyncio.create_task(run_pipeline())
    
    async def generate():
        # Send initial starting event
        yield f"data: {json.dumps({'status': 'starting', 'widget_id': widget_id})}\n\n"
        
        try:
            while True:
                event = await event_queue.get()
                if event is None:
                    break
                yield f"data: {json.dumps(event)}\n\n"
        finally:
            if not pipeline_task.done():
                pipeline_task.cancel()
    
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

@router.post("/{widget_id}/schedule")
async def schedule_refresh(
    widget_id: str,
    request: ScheduleRequest,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    """Schedule periodic refresh for a widget."""
    schedule_widget_refresh(widget_id, str(user.id), request.interval_minutes)
    return {
        "status": "scheduled",
        "widget_id": widget_id,
        "interval_minutes": request.interval_minutes
    }

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
    # Trigger notification for certain actions
    if request.action == "goal_completed":
        from app.api.notifications import trigger_notification, NotificationTrigger
        await trigger_notification(user.id, NotificationTrigger(
            type="goal_achievement",
            title="Goal Achieved!",
            message=f"You completed your goal in {widget_id}.",
            data={"widget_id": widget_id, "action": request.action}
        ))
    
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


@router.post("/jobs/{widget_id}")
async def submit_widget_job(widget_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Submit a widget refresh job to the queue."""
    job_id = await job_queue.submit(widget_id, user.id, {})
    return {"job_id": job_id, "status": "submitted"}


@router.get("/jobs/{job_id}")
async def get_job_status(job_id: str, user=Depends(get_current_user)):
    """Get the status of a widget job."""
    job = job_queue.get_job(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return job.to_dict()


@router.get("/jobs")
async def list_user_jobs(user=Depends(get_current_user)):
    """List recent jobs for the user."""
    jobs = job_queue.get_user_jobs(user.id)
    return {"jobs": jobs}


@router.get("/jobs/stats")
async def get_queue_stats(user=Depends(get_current_user)):
    """Get queue statistics."""
    return {"pending_jobs": job_queue.queue_size()}