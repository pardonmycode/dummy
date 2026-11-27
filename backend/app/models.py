from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey, Text, JSON, Boolean
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
from datetime import datetime
from app.config import settings

Base = declarative_base()
engine = create_engine(settings.DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    name = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    dashboards = relationship("Dashboard", back_populates="user", cascade="all, delete-orphan")
    tracker_entries = relationship("TrackerEntry", back_populates="user", cascade="all, delete-orphan")
    device_tokens = relationship("DeviceToken", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
    push_logs = relationship("PushNotificationLog", back_populates="user", cascade="all, delete-orphan")
    notification_preferences = relationship("NotificationPreferences", back_populates="user", uselist=False, cascade="all, delete-orphan")

class Dashboard(Base):
    __tablename__ = "dashboards"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String, nullable=False)
    layout = Column(JSON, default={})
    created_at = Column(DateTime, default=datetime.utcnow)
    user = relationship("User", back_populates="dashboards")

class WidgetInstance(Base):
    __tablename__ = "widget_instances"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    widget_type = Column(String, nullable=False)
    size = Column(String, default="M")
    config = Column(JSON, default={})
    data = Column(JSON, default={})
    generated_at = Column(DateTime)
    expires_at = Column(DateTime)
    user = relationship("User")

class WidgetRun(Base):
    __tablename__ = "widget_runs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    widget_id = Column(Integer, ForeignKey("widget_instances.id"), nullable=False)
    status = Column(String, default="pending")
    prompt = Column(Text)
    response = Column(Text)
    sources = Column(JSON, default=[])
    tokens_used = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime)
    user = relationship("User")
    widget = relationship("WidgetInstance")

class TrackerEntry(Base):
    __tablename__ = "tracker_entries"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    tracker_type = Column(String, nullable=False)
    value = Column(Float, nullable=False)
    unit = Column(String, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    note = Column(String)
    meal_name = Column(String)
    user = relationship("User")

# Push notification models
class DeviceToken(Base):
    """FCM device token for push notifications."""
    __tablename__ = "device_tokens"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    token = Column(String, unique=True, index=True, nullable=False)
    platform = Column(String, default="unknown")  # android, ios, web
    registered_at = Column(DateTime, default=datetime.utcnow)
    last_used_at = Column(DateTime)
    active = Column(Boolean, default=True)
    user = relationship("User", back_populates="device_tokens")

class Notification(Base):
    """Stored notification for a user."""
    __tablename__ = "notifications"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    type = Column(String, nullable=False)  # weather_alert, party_reminder, tracker_goal, etc.
    title = Column(String, nullable=False)
    message = Column(String, nullable=False)
    data = Column(JSON, default={})
    read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    user = relationship("User", back_populates="notifications")

class PushNotificationLog(Base):
    """History of push notifications sent via FCM."""
    __tablename__ = "push_notification_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    device_token_id = Column(Integer, ForeignKey("device_tokens.id"), nullable=True)
    type = Column(String, nullable=False)
    title = Column(String, nullable=False)
    message = Column(String, nullable=False)
    data = Column(JSON, default={})
    status = Column(String, default="sent")  # sent, failed, delivered
    fcm_message_id = Column(String)
    error = Column(String)
    sent_at = Column(DateTime, default=datetime.utcnow)
    user = relationship("User", back_populates="push_logs")

class NotificationPreferences(Base):
    """User notification preferences."""
    __tablename__ = "notification_preferences"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False, index=True)
    weather_warnings = Column(Boolean, default=True)
    goal_achievements = Column(Boolean, default=True)
    data_refreshes = Column(Boolean, default=False)
    ai_insights = Column(Boolean, default=True)
    email_notifications = Column(Boolean, default=False)
    push_notifications = Column(Boolean, default=True)
    user = relationship("User", back_populates="notification_preferences")
