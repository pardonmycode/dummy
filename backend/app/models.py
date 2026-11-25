from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey, Text, JSON
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