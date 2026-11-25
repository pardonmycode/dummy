import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///widgetly.db")
    SECRET_KEY = os.getenv("SECRET_KEY", "widgetly-secret-key-2025")
    ALGORITHM = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24
    
    # AI
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
    OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
    
    # Weather
    OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "")
    
    # Rate limiting
    RATE_LIMIT = "100/minute"

settings = Settings()