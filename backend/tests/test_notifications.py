"""Tests for push notification infrastructure."""
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.push_notifications import (
    fcm_service,
    build_notification_message,
    NOTIFICATION_TYPES,
)
from app.models import get_db
from app.auth import get_password_hash, create_access_token
from datetime import datetime

client = TestClient(app)


def get_test_token(user_id=1):
    """Create a test JWT token."""
    return create_access_token(data={"sub": str(user_id)})


def setup_test_user(db):
    """Create a test user for notification tests."""
    from app.models import User

    # Check if user exists
    user = db.query(User).filter(User.email == "notif_test@example.com").first()
    if user:
        return user

    user = User(
        email="notif_test@example.com",
        password_hash=get_password_hash("testpassword"),
        name="Notification Test User",
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


class TestFCMMessageBuilding:
    """Tests for FCM message construction."""

    def test_build_basic_notification(self):
        msg = build_notification_message(
            token="test-token-123",
            title="Test Title",
            body="Test Body",
            notification_type="system",
        )
        msg_dict = msg.to_dict()
        assert msg_dict["token"] == "test-token-123"
        assert msg_dict["notification"]["title"] == "Test Title"
        assert msg_dict["notification"]["body"] == "Test Body"
        assert msg_dict["priority"] == "low"

    def test_build_weather_alert(self):
        msg = build_notification_message(
            token="test-token",
            title="Wetterwarnung",
            body="Starker Sturm",
            notification_type="weather_alert",
        )
        msg_dict = msg.to_dict()
        assert msg_dict["priority"] == "high"
        assert msg_dict["data"]["type"] == "weather_alert"
        assert "android" in msg_dict
        assert "apns" in msg_dict

    def test_build_with_data(self):
        msg = build_notification_message(
            token="test-token",
            title="Test",
            body="Test",
            notification_type="tracker_goal",
            data={"value": 100, "unit": "steps"},
        )
        msg_dict = msg.to_dict()
        # Data values should be strings (FCM requirement)
        assert isinstance(msg_dict["data"]["value"], str)
        assert isinstance(msg_dict["data"]["unit"], str)

    def test_notification_types_exist(self):
        assert "weather_alert" in NOTIFICATION_TYPES
        assert "party_reminder" in NOTIFICATION_TYPES
        assert "tracker_goal" in NOTIFICATION_TYPES
        assert "tracker_milestone" in NOTIFICATION_TYPES
        assert "ai_insight" in NOTIFICATION_TYPES
        assert "system" in NOTIFICATION_TYPES


class TestFCMServiceMock:
    """Tests for the mock FCM service."""

    def setup_method(self):
        fcm_service.sent_messages.clear()

    def test_send_message(self):
        msg = build_notification_message(
            token="test-token",
            title="Test",
            body="Test",
            notification_type="system",
        )
        response = fcm_service.send(msg)
        assert "name" in response
        assert "message_id" in response
        assert fcm_service.get_sent_count() == 1

    def test_send_batch(self):
        messages = [
            build_notification_message(token="t1", title="T1", body="B1"),
            build_notification_message(token="t2", title="T2", body="B2"),
        ]
        response = fcm_service.send_batch(messages)
        assert response["total"] == 2
        assert fcm_service.get_sent_count() == 2


class TestNotificationEndpoints:
    """Integration tests for notification API endpoints."""

    def setup_method(self):
        # Reset FCM sent messages
        fcm_service.sent_messages.clear()

        # Get test user
        db = next(get_db())
        try:
            self.user = setup_test_user(db)
            self.token = get_test_token(self.user.id)
        finally:
            db.close()

    def test_get_notifications_empty(self):
        response = client.get(
            "/api/notifications/notifications",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "notifications" in data

    def test_trigger_in_app_notification(self):
        response = client.post(
            "/api/notifications/trigger",
            headers={"Authorization": f"Bearer {self.token}"},
            json={
                "type": "system",
                "title": "Test Notification",
                "message": "This is a test",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert "notification_id" in data

    def test_mark_notification_read(self):
        # First trigger a notification
        response = client.post(
            "/api/notifications/trigger",
            headers={"Authorization": f"Bearer {self.token}"},
            json={
                "type": "system",
                "title": "To Read",
                "message": "Mark as read test",
            },
        )
        notif_id = response.json()["notification_id"]

        # Then mark it read
        response = client.post(
            f"/api/notifications/notifications/{notif_id}/read",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200

    def test_mark_all_notifications_read(self):
        response = client.post(
            "/api/notifications/notifications/read-all",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200

    def test_device_token_registration(self):
        response = client.post(
            "/api/notifications/device-tokens",
            headers={"Authorization": f"Bearer {self.token}"},
            json={"token": "test-fcm-token-123", "platform": "android"},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"

    def test_list_device_tokens(self):
        # Register a token first
        client.post(
            "/api/notifications/device-tokens",
            headers={"Authorization": f"Bearer {self.token}"},
            json={"token": "list-test-token", "platform": "ios"},
        )

        response = client.get(
            "/api/notifications/device-tokens",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "tokens" in data

    def test_send_push_notification_no_devices(self):
        response = client.post(
            "/api/notifications/push",
            headers={"Authorization": f"Bearer {self.token}"},
            json={
                "type": "system",
                "title": "Push Test",
                "message": "Push test message",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"

    def test_weather_alert_trigger(self):
        response = client.post(
            "/api/notifications/push/weather-alert",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200

    def test_party_reminder_trigger(self):
        response = client.post(
            "/api/notifications/push/party-reminder",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200

    def test_tracker_goal_trigger(self):
        response = client.post(
            "/api/notifications/push/tracker-goal",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200

    def test_ai_insight_trigger(self):
        response = client.post(
            "/api/notifications/push/ai-insight",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200

    def test_notification_history(self):
        response = client.get(
            "/api/notifications/history",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "history" in data

    def test_preferences_get(self):
        response = client.get(
            "/api/notifications/preferences",
            headers={"Authorization": f"Bearer {self.token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "preferences" in data

    def test_preferences_update(self):
        response = client.put(
            "/api/notifications/preferences",
            headers={"Authorization": f"Bearer {self.token}"},
            json={"weather_warnings": False, "ai_insights": False},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["preferences"]["weather_warnings"] == False

    def test_invalid_notification_type(self):
        response = client.post(
            "/api/notifications/push",
            headers={"Authorization": f"Bearer {self.token}"},
            json={
                "type": "invalid_type",
                "title": "Test",
                "message": "Test",
            },
        )
        assert response.status_code == 400
