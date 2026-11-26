from contextlib import asynccontextmanager
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
from app.api import notifications
from app.models import Base, engine
from app.scheduler import start_scheduler, shutdown_scheduler
from app.ai.job_queue import job_queue

# Rate limiter
limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])

@asynccontextmanager
async def lifespan(app):
    # Startup
    Base.metadata.create_all(bind=engine)
    start_scheduler()
    await job_queue.start()
    yield
    # Shutdown
    shutdown_scheduler()
    await job_queue.stop()

app = FastAPI(
    title="Widgetly Backend",
    description="KI-gesteuerte Widget-Plattform",
    version="0.3.0",
    lifespan=lifespan,
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
app.include_router(notifications.router, prefix="/api/notifications", tags=["notifications"])

@app.get("/")
async def root():
    return {"message": "Widgetly Backend API"}

@app.get("/health")
async def health():
    return {"status": "ok"}