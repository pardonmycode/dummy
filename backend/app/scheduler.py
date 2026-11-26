import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from app.models import get_db
from app.ai.pipeline import run_widget_pipeline

logger = logging.getLogger(__name__)

scheduler = AsyncIOScheduler()

async def scheduled_widget_refresh(widget_id: str, user_id: int):
    """Scheduled refresh for a widget."""
    db = get_db().__next__()
    try:
        from app.models import WidgetInstance
        widget = db.query(WidgetInstance).filter(
            WidgetInstance.user_id == user_id,
            WidgetInstance.widget_type == widget_id
        ).first()
        
        if widget:
            data = await run_widget_pipeline(widget_id, {"user_id": user_id})
            widget.data = data
            db.commit()
    except Exception as e:
        logger.error(f"Scheduled refresh error for {widget_id}: {e}")
    finally:
        db.close()

def schedule_widget_refresh(widget_id: str, user_id: str, interval_minutes: int = 30):
    """Schedule a widget to refresh periodically."""
    scheduler.add_job(
        scheduled_widget_refresh,
        'interval',
        minutes=interval_minutes,
        args=[widget_id, int(user_id)],
        id=f"refresh_{user_id}_{widget_id}",
        replace_existing=True
    )

def start_scheduler():
    scheduler.start()

def shutdown_scheduler():
    scheduler.shutdown()