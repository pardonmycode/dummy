from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import widgets
from app.api import auth
from app.api import dashboard
from app.api import tracker

app = FastAPI(
    title="Widgetly Backend",
    description="KI-gesteuerte Widget-Plattform",
    version="0.1.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(widgets.router, prefix="/api/widgets", tags=["widgets"])
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(dashboard.router, prefix="/api/dashboard", tags=["dashboard"])
app.include_router(tracker.router, prefix="/api/tracker", tags=["tracker"])

@app.get("/")
async def root():
    return {"message": "Widgetly Backend API"}

@app.get("/health")
async def health():
    return {"status": "ok"}
