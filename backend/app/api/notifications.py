import logging
from datetime import datetime, timezone
from typing import Optional

logger = logging.getLogger(__name__)
from fastapi import APIRouter, HTTPException, Depends, Query
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.auth import get_current_user
from app.models import User, Notification, DeviceToken, PushNotificationLog, NotificationPreferences, get_db
from app.push_notifications import (
    fcm_service,
    build_notification_message,
    send_weather_alert,
    send_party_reminder,
    send_tracker_goal,
    send_tracker_milestone,
    send_ai_insight,
    NOTIFICATION_TYPES,
)

router = APIRouter()


# Request/Response models
class NotificationCreate(BaseModel):
    type: str
    title: str
    message: str
    data: Optional[dict] = None


class NotificationResponse(BaseModel):
    id: int
    type: str
    title: str
    message: str
    data: Optional[dict] = None
    read: bool
    created_at: datetime


class DeviceTokenRequest(BaseModel):
    token: str
    platform: str = "unknown"


class PushTriggerRequest(BaseModel):
    type: str  # weather_alert, party_reminder, tracker_goal, tracker_milestone, ai_insight
    title: str
    message: str
    data: Optional[dict] = None


class PushLogResponse(BaseModel):
    id: int
    type: str
    title: str
    message: str
    status: str
    sent_at: datetime


# Notification preference models
class NotificationPreferencesRequest(BaseModel):
    weather_warnings: bool = True
    goal_achievements: bool = True
    data_refreshes: bool = False
    ai_insights: bool = True
    email_notifications: bool = False
    push_notifications: bool = True


def get_user_preferences(db: Session, user_id: int) -> dict:
    """Get notification preferences from database."""
    prefs = db.query(NotificationPreferences).filter(
        NotificationPreferences.user_id == user_id
    ).first()
    
    if prefs is None:
        # Create default preferences if not exist
        prefs = NotificationPreferences(
            user_id=user_id,
            weather_warnings=True,
            goal_achievements=True,
            data_refreshes=False,
            ai_insights=True,
            email_notifications=False,
            push_notifications=True
        )
        db.add(prefs)
        db.commit()
    
    return {
        "weather_warnings": prefs.weather_warnings,
        "goal_achievements": prefs.goal_achievements,
        "data_refreshes": prefs.data_refreshes,
        "ai_insights": prefs.ai_insights,
        "email_notifications": prefs.email_notifications,
        "push_notifications": prefs.push_notifications
    }


# In-app notification endpoints
@router.get("/notifications", response_model=dict)
async def list_notifications(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    unread_only: bool = Query(False),
    limit: int = Query(50, le=100),
):
    """Get notifications for the current user."""
    query = db.query(Notification).filter(Notification.user_id == user.id)
    if unread_only:
        query = query.filter(Notification.read == False)
    query = query.order_by(Notification.created_at.desc()).limit(limit)
    notifs = query.all()
    return {
        "notifications": [n.__dict__ for n in notifs if "_sa_instance_state" not in n.__dict__],
        "count": len(notifs),
    }


@router.post("/notifications/{notification_id}/read")
async def mark_notification_read(
    notification_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Mark a notification as read."""
    notif = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == user.id,
    ).first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    notif.read = True
    db.commit()
    return {"status": "ok"}


@router.post("/notifications/read-all")
async def mark_all_notifications_read(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Mark all notifications as read."""
    db.query(Notification).filter(
        Notification.user_id == user.id,
        Notification.read == False,
    ).update({"read": True})
    db.commit()
    return {"status": "ok"}


@router.delete("/notifications/{notification_id}")
async def delete_notification(
    notification_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Delete a notification."""
    notif = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == user.id,
    ).first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    db.delete(notif)
    db.commit()
    return {"status": "ok"}


# Device token management endpoints
@router.post("/device-tokens")
async def register_device_token(
    req: DeviceTokenRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Register a device token for push notifications."""
    # Check if token already exists
    existing = db.query(DeviceToken).filter(DeviceToken.token == req.token).first()
    if existing:
        if existing.user_id != user.id:
            raise HTTPException(status_code=400, detail="Token already registered to another user")
        # Update last used
        existing.last_used_at = datetime.now(timezone.utc)
        db.commit()
        return {"status": "ok", "token_id": existing.id}

    token = DeviceToken(
        user_id=user.id,
        token=req.token,
        platform=req.platform,
    )
    db.add(token)
    db.commit()
    db.refresh(token)
    return {"status": "ok", "token_id": token.id}


@router.get("/device-tokens")
async def list_device_tokens(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """List all device tokens for the current user."""
    tokens = db.query(DeviceToken).filter(
        DeviceToken.user_id == user.id,
        DeviceToken.active == True,
    ).all()
    return {"tokens": [{"id": t.id, "platform": t.platform, "registered_at": t.registered_at} for t in tokens]}


@router.delete("/device-tokens/{token_id}")
async def unregister_device_token(
    token_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Unregister a device token."""
    token = db.query(DeviceToken).filter(
        DeviceToken.id == token_id,
        DeviceToken.user_id == user.id,
    ).first()
    if not token:
        raise HTTPException(status_code=404, detail="Device token not found")
    token.active = False
    db.commit()
    return {"status": "ok"}


# Push notification trigger endpoints
@router.post("/push")
async def send_push_notification(
    req: PushTriggerRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Send a push notification to all of the user's devices."""
    # Validate notification type
    if req.type not in NOTIFICATION_TYPES:
        valid_types = list(NOTIFICATION_TYPES.keys())
        raise HTTPException(
            status_code=400,
            detail=f"Invalid notification type. Must be one of: {valid_types}",
        )

    # Get user's device tokens
    tokens = db.query(DeviceToken).filter(
        DeviceToken.user_id == user.id,
        DeviceToken.active == True,
    ).all()

    if not tokens:
        return {"status": "ok", "sent_to": 0, "message": "No registered devices"}

    sent_count = 0
    for device_token in tokens:
        try:
            fcm_msg = build_notification_message(
                token=device_token.token,
                title=req.title,
                body=req.message,
                notification_type=req.type,
                data=req.data,
            )
            response = fcm_service.send(fcm_msg)
            device_token.last_used_at = datetime.now(timezone.utc)
            sent_count += 1

            # Log push notification
            log_entry = PushNotificationLog(
                user_id=user.id,
                device_token_id=device_token.id,
                type=req.type,
                title=req.title,
                message=req.message,
                data=req.data or {},
                status="sent",
                fcm_message_id=response.get("message_id"),
            )
            db.add(log_entry)
        except Exception as e:
            # Log failed push
            log_entry = PushNotificationLog(
                user_id=user.id,
                device_token_id=device_token.id,
                type=req.type,
                title=req.title,
                message=req.message,
                data=req.data or {},
                status="failed",
                error=str(e),
            )
            db.add(log_entry)

    db.commit()
    return {"status": "ok", "sent_to": sent_count, "devices": len(tokens)}


# Convenience endpoints for specific notification types
@router.post("/push/weather-alert")
async def trigger_weather_alert(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Send a weather alert to the user."""
    location = "Berlin"  # Would come from user settings in real app
    alert = "Starker Sturm mit Windböen bis 100 km/h erwartet. Bitte bleiben Sie in der Nähe von Gebäuden."

    tokens = db.query(DeviceToken).filter(
        DeviceToken.user_id == user.id,
        DeviceToken.active == True,
    ).all()

    for device_token in tokens:
        try:
            send_weather_alert(str(device_token.token), location, alert)
        except Exception as e:
            logger.error(f"[Weather Alert] Failed to send to {device_token.id}: {e}")

    # Store in-app notification
    notif = Notification(
        user_id=user.id,
        type="weather_alert",
        title=f"⚠️ Wetterwarnung: {location}",
        message=alert,
        data={"location": location},
    )
    db.add(notif)
    db.commit()

    return {"status": "ok", "sent": len(tokens)}


@router.post("/push/party-reminder")
async def trigger_party_reminder(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Send a party reminder to the user."""
    party_name = "Silvester-Party"
    time_remaining = "30 Minuten"

    tokens = db.query(DeviceToken).filter(
        DeviceToken.user_id == user.id,
        DeviceToken.active == True,
    ).all()

    for device_token in tokens:
        try:
            send_party_reminder(str(device_token.token), party_name, time_remaining)
        except Exception as e:
            logger.error(f"[Party Reminder] Failed to send to {device_token.id}: {e}")

    # Store in-app notification
    notif = Notification(
        user_id=user.id,
        type="party_reminder",
        title=f"🎉 Erinnerung: {party_name}",
        message=f"Die Party beginnt in {time_remaining}!",
        data={"party": party_name},
    )
    db.add(notif)
    db.commit()

    return {"status": "ok", "sent": len(tokens)}


@router.post("/push/tracker-goal")
async def trigger_tracker_goal(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Send a tracker goal achievement notification."""
    goal = "Schritte"
    value = "10.000"
    unit = "Schritte"

    tokens = db.query(DeviceToken).filter(
        DeviceToken.user_id == user.id,
        DeviceToken.active == True,
    ).all()

    for device_token in tokens:
        try:
            send_tracker_goal(str(device_token.token), goal, value, unit)
        except Exception as e:
            logger.error(f"[Tracker Goal] Failed to send to {device_token.id}: {e}")

    # Store in-app notification
    notif = Notification(
        user_id=user.id,
        type="tracker_goal",
        title=f"🎯 Ziel erreicht: {goal}",
        message=f"Du hast {value} {unit} erreicht!",
        data={"goal": goal, "value": value, "unit": unit},
    )
    db.add(notif)
    db.commit()

    return {"status": "ok", "sent": len(tokens)}


@router.post("/push/ai-insight")
async def trigger_ai_insight(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Send an AI-generated insight notification."""
    tokens = db.query(DeviceToken).filter(
        DeviceToken.user_id == user.id,
        DeviceToken.active == True,
    ).all()

    for device_token in tokens:
        try:
            send_ai_insight(
                str(device_token.token),
                "Gesundheits-Tipp",
                "Deine Schlafqualität hat sich die letzte Woche verbessert. Weiter so!",
            )
        except Exception as e:
            logger.error(f"[AI Insight] Failed to send to {device_token.id}: {e}")

    # Store in-app notification
    notif = Notification(
        user_id=user.id,
        type="ai_insight",
        title="🤖 KI-Einsicht: Gesundheits-Tipp",
        message="Deine Schlafqualität hat sich die letzte Woche verbessert. Weiter so!",
        data={},
    )
    db.add(notif)
    db.commit()

    return {"status": "ok", "sent": len(tokens)}


# Notification history endpoint
@router.get("/history")
async def get_push_notification_history(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    limit: int = Query(50, le=100),
):
    """Get history of push notifications sent to the user."""
    logs = db.query(PushNotificationLog).filter(
        PushNotificationLog.user_id == user.id,
    ).order_by(PushNotificationLog.sent_at.desc()).limit(limit).all()

    return {
        "history": [
            {
                "id": log.id,
                "type": log.type,
                "title": log.title,
                "message": log.message,
                "status": log.status,
                "sent_at": log.sent_at.isoformat(),
            }
            for log in logs
        ],
        "count": len(logs),
    }


# Preferences endpoints
@router.get("/preferences")
async def get_preferences(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get notification preferences."""
    prefs = get_user_preferences(db, user.id)
    return {"preferences": prefs}


@router.put("/preferences")
async def update_preferences(
    prefs_request: NotificationPreferencesRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Update notification preferences."""
    prefs = db.query(NotificationPreferences).filter(
        NotificationPreferences.user_id == user.id
    ).first()
    
    if prefs is None:
        prefs = NotificationPreferences(user_id=user.id)
        db.add(prefs)
    
    prefs.weather_warnings = prefs_request.weather_warnings
    prefs.goal_achievements = prefs_request.goal_achievements
    prefs.data_refreshes = prefs_request.data_refreshes
    prefs.ai_insights = prefs_request.ai_insights
    prefs.email_notifications = prefs_request.email_notifications
    prefs.push_notifications = prefs_request.push_notifications
    
    db.commit()
    
    return {
        "status": "ok",
        "preferences": get_user_preferences(db, user.id)
    }


# Test trigger endpoint (for development)
@router.post("/trigger")
async def test_trigger_notification(
    req: NotificationCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Trigger a test in-app notification."""
    notif = Notification(
        user_id=user.id,
        type=req.type,
        title=req.title,
        message=req.message,
        data=req.data,
    )
    db.add(notif)
    db.commit()
    return {"status": "ok", "notification_id": notif.id}
