from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from fastapi.responses import JSONResponse

from app.api import widgets
from app import auth
from app.api import dashboard
from app.api import tracker
from app.models import Base, engine
from app.scheduler import start_scheduler, shutdown_scheduler

# Rate limiter
limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])

app = FastAPI(
    title="Widgetly Backend",
    description="KI-gesteuerte Widget-Plattform",
    version="0.3.0"
)

app.state.limiter = limiter

@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request, exc):
    return JSONResponse(
        status_code=429,
        content={"detail": "Rate limit exceeded"}
    )

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8092", "http://127.0.0.1:8092"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(widgets.router, prefix="/api/widgets", tags=["widgets"])
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(dashboard.router, prefix="/api/dashboard", tags=["dashboard"])
app.include_router(tracker.router, prefix="/api/tracker", tags=["tracker"])

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)
    start_scheduler()

@app.on_event("shutdown")
async def shutdown():
    shutdown_scheduler()

@app.get("/")
async def root():
    return {"message": "Widgetly Backend API"}

@app.get("/health")
async def health():
    return {"status": "ok"}