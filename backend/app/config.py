import os
import secrets
import warnings
from dotenv import load_dotenv

load_dotenv()

class Settings:
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///widgetly.db")
    SECRET_KEY = os.getenv("SECRET_KEY") or secrets.token_urlsafe(48)
    if not os.getenv("SECRET_KEY") and os.getenv("ENVIRONMENT") == "production":
        warnings.warn("SECRET_KEY not set in production; using random default that changes on restart", stacklevel=2)
    ALGORITHM = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24
    
    # AI
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
    OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
    
    # Weather
    OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "")
    
    # FCM Push Notifications
    FCM_PROJECT_ID = os.getenv("FCM_PROJECT_ID", "widgetly-project")
    FCM_API_KEY = os.getenv("FCM_API_KEY", "")
    
    # Rate limiting
    RATE_LIMIT = "100/minute"

settings = Settings()
