"""
Push notification service using FCM HTTP API pattern (mocked for development).

Supports notification types:
- weather_alert: Weather warnings and severe weather
- party_reminder: Party/event reminders
- tracker_goal: Fitness tracker goal achievements
- tracker_milestone: Milestone notifications
- ai_insight: AI-generated insights
- system: General system notifications
"""

import json
import logging
import time
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)

# Notification type enum
from enum import Enum

class NotificationType(str, Enum):
    WEATHER_ALERT = "weather_alert"
    PARTY_REMINDER = "party_reminder"
    TRACKER_GOAL = "tracker_goal"
    TRACKER_MILESTONE = "tracker_milestone"
    AI_INSIGHT = "ai_insight"
    SYSTEM = "system"

# Notification type constants (using enum values)
NOTIFICATION_TYPES = {
    NotificationType.WEATHER_ALERT.value: {"icon": "☀️", "priority": "high"},
    NotificationType.PARTY_REMINDER.value: {"icon": "🎉", "priority": "high"},
    NotificationType.TRACKER_GOAL.value: {"icon": "🎯", "priority": "medium"},
    NotificationType.TRACKER_MILESTONE.value: {"icon": "🏆", "priority": "medium"},
    NotificationType.AI_INSIGHT.value: {"icon": "🤖", "priority": "low"},
    NotificationType.SYSTEM.value: {"icon": "🔔", "priority": "low"},
}


@dataclass
class FCMMessage:
    """FCM HTTP v1 API message structure."""
    token: Optional[str] = None
    notification: Optional[Dict[str, Any]] = None
    data: Optional[Dict[str, str]] = None
    priority: str = "high"
    android: Optional[Dict[str, Any]] = None
    apns: Optional[Dict[str, Any]] = None
    topic: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        msg = {}
        if self.token:
            msg["token"] = self.token
        if self.notification:
            msg["notification"] = self.notification
        if self.data:
            msg["data"] = self.data
        if self.priority:
            msg["priority"] = self.priority
        if self.android:
            msg["android"] = self.android
        if self.apns:
            msg["apns"] = self.apns
        if self.topic:
            msg["topic"] = self.topic
        return msg


class FCMService:
    """
    Mock FCM service that simulates sending push notifications.
    
    In production, this would POST to https://fcm.googleapis.com/v1/projects/{project_id}/messages:send
    with an OAuth 2.0 bearer token.
    """

    def __init__(self, project_id: str = "widgetly-project", api_key: str = ""):
        self.project_id = project_id
        self.api_key = api_key
        self.sent_messages: List[Dict[str, Any]] = []
        self.fcm_url = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"

    def send(self, message: FCMMessage) -> Dict[str, Any]:
        """Send a push notification (mocked)."""
        msg_dict = message.to_dict()
        
        # Validate message structure
        if not msg_dict.get("token") and not msg_dict.get("topic"):
            raise ValueError("Message must have either a token or topic")

        # Mock response
        response = {
            "name": f"projects/{self.project_id}/messages/{uuid.uuid4().hex[:12]}",
            "sent_at": datetime.now(timezone.utc).isoformat(),
            "message_id": str(uuid.uuid4()),
        }

        # Log sent message
        self.sent_messages.append({
            "message": msg_dict,
            "response": response,
            "timestamp": time.time(),
        })

        logger.info(f"[FCM MOCK] Sent notification: {msg_dict.get('notification', {}).get('title', 'untitled')}")
        return response

    def send_batch(self, messages: List[FCMMessage]) -> Dict[str, Any]:
        """Send multiple push notifications (mocked)."""
        results = []
        for msg in messages:
            try:
                result = self.send(msg)
                results.append({"success": True, "response": result})
            except Exception as e:
                results.append({"success": False, "error": str(e)})
        return {"results": results, "total": len(results)}

    def get_sent_count(self) -> int:
        """Get count of sent notifications (for testing)."""
        return len(self.sent_messages)


# Global FCM service instance
fcm_service = FCMService()


def build_notification_message(
    token: str,
    title: str,
    body: str,
    notification_type: str = "system",
    data: Optional[Dict[str, Any]] = None,
) -> FCMMessage:
    """Build an FCM message from notification parameters."""
    # Validate title length (Android max 100 chars)
    if len(title) > 100:
        logger.warning(f"Notification title exceeds 100 characters, truncating")
        title = title[:100]
    
    # Validate body length
    if len(body) > 2000:
        logger.warning(f"Notification body exceeds 2000 characters, truncating")
        body = body[:2000]
    
    type_info = NOTIFICATION_TYPES.get(notification_type, NOTIFICATION_TYPES["system"])

    notification = {
        "title": title,
        "body": body,
    }

    # Convert data to string values (FCM requirement)
    data_payload = {}
    if data:
        for k, v in data.items():
            data_payload[k] = json.dumps(v) if not isinstance(v, str) else v
    data_payload["type"] = notification_type
    data_payload["icon"] = type_info["icon"]

    # Android-specific config
    android = {
        "notification": {
            "icon": "ic_notification",
            "channel_id": notification_type,
            "priority": "PRIORITY_HIGH" if type_info["priority"] == "high" else "PRIORITY_DEFAULT",
            "sound": "default" if type_info["priority"] == "high" else None,
        }
    }

    # iOS-specific config
    apns = {
        "payload": {
            "aps": {
                "sound": "default" if type_info["priority"] == "high" else None,
                "badge": 1,
                "category": notification_type.upper(),
            }
        }
    }

    return FCMMessage(
        token=token,
        notification=notification,
        data=data_payload,
        android=android,
        apns=apns,
        priority=type_info["priority"],
    )


def send_weather_alert(token: str, location: str, alert: str) -> Dict[str, Any]:
    """Send a weather alert push notification."""
    msg = build_notification_message(
        token=token,
        title=f"⚠️ Wetterwarnung: {location}",
        body=alert,
        notification_type=NotificationType.WEATHER_ALERT.value,
        data={"location": location},
    )
    return fcm_service.send(msg)


def send_party_reminder(token: str, party_name: str, time_remaining: str) -> Dict[str, Any]:
    """Send a party/event reminder push notification."""
    msg = build_notification_message(
        token=token,
        title=f"🎉 Erinnerung: {party_name}",
        body=f"Die Party beginnt in {time_remaining}!",
        notification_type=NotificationType.PARTY_REMINDER.value,
        data={"party": party_name},
    )
    return fcm_service.send(msg)


def send_tracker_goal(token: str, goal: str, value: str, unit: str) -> Dict[str, Any]:
    """Send a tracker goal achievement notification."""
    msg = build_notification_message(
        token=token,
        title=f"🎯 Ziel erreicht: {goal}",
        body=f"Du hast {value} {unit} erreicht!",
        notification_type=NotificationType.TRACKER_GOAL.value,
        data={"goal": goal, "value": value, "unit": unit},
    )
    return fcm_service.send(msg)


def send_tracker_milestone(token: str, milestone: str, description: str) -> Dict[str, Any]:
    """Send a tracker milestone notification."""
    msg = build_notification_message(
        token=token,
        title=f"🏆 Meilenstein: {milestone}",
        body=description,
        notification_type=NotificationType.TRACKER_MILESTONE.value,
        data={"milestone": milestone},
    )
    return fcm_service.send(msg)


def send_ai_insight(token: str, title: str, insight: str, widget_type: str = "") -> Dict[str, Any]:
    """Send an AI-generated insight notification."""
    msg = build_notification_message(
        token=token,
        title=f"🤖 KI-Einsicht: {title}",
        body=insight,
        notification_type=NotificationType.AI_INSIGHT.value,
        data={"widget": widget_type},
    )
    return fcm_service.send(msg)
