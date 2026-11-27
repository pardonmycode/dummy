from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, ConfigDict
from typing import List, Optional
from sqlalchemy.orm import Session

from app.models import Dashboard, get_db
from app.auth import get_current_user, User

router = APIRouter()

class DashboardCreate(BaseModel):
    name: str
    layout: Optional[dict] = None

class DashboardUpdate(BaseModel):
    name: Optional[str] = None
    layout: Optional[dict] = None

class DashboardResponse(BaseModel):
    id: int
    user_id: int
    name: str
    layout: dict
    created_at: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

@router.get("/")
async def list_dashboards(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    dashboards = db.query(Dashboard).filter(
        Dashboard.user_id == current_user.id
    ).all()
    return {"dashboards": [
        {
            "id": d.id,
            "user_id": d.user_id,
            "name": d.name,
            "layout": d.layout,
            "created_at": d.created_at.isoformat() if d.created_at is not None else None
        }
        for d in dashboards
    ]}

@router.get("/{dashboard_id}")
async def get_dashboard(
    dashboard_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    dashboard = db.query(Dashboard).filter(
        Dashboard.id == dashboard_id,
        Dashboard.user_id == current_user.id
    ).first()
    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")
    return {
        "id": dashboard.id,
        "user_id": dashboard.user_id,
        "name": dashboard.name,
        "layout": dashboard.layout,
        "created_at": dashboard.created_at.isoformat() if dashboard.created_at is not None else None
    }

@router.post("/")
async def create_dashboard(
    request: DashboardCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    dashboard = Dashboard(
        user_id=current_user.id,
        name=request.name,
        layout=request.layout or {}
    )
    db.add(dashboard)
    db.commit()
    db.refresh(dashboard)
    return {
        "id": dashboard.id,
        "name": dashboard.name,
        "layout": dashboard.layout,
        "message": "Dashboard created"
    }

@router.put("/{dashboard_id}")
async def update_dashboard(
    dashboard_id: int,
    request: DashboardUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    dashboard = db.query(Dashboard).filter(
        Dashboard.id == dashboard_id,
        Dashboard.user_id == current_user.id
    ).first()
    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")
    
    if request.name is not None:
        dashboard.name = request.name  # type: ignore[assignment]
    if request.layout is not None:
        dashboard.layout = request.layout  # type: ignore[assignment]
    
    db.commit()
    db.refresh(dashboard)
    return {
        "id": dashboard.id,
        "name": dashboard.name,
        "layout": dashboard.layout,
        "message": "Dashboard updated"
    }

@router.delete("/{dashboard_id}")
async def delete_dashboard(
    dashboard_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    dashboard = db.query(Dashboard).filter(
        Dashboard.id == dashboard_id,
        Dashboard.user_id == current_user.id
    ).first()
    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")
    
    db.delete(dashboard)
    db.commit()
    return {"message": "Dashboard deleted"}

# Layout sync endpoints

class SyncRequest(BaseModel):
    dashboards: List[dict]

@router.post("/sync")
async def sync_layouts(
    request: SyncRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Sync all dashboards from client to server. Overwrites server state."""
    # Delete existing dashboards
    db.query(Dashboard).filter(Dashboard.user_id == current_user.id).delete()
    
    # Insert synced dashboards
    synced = []
    for d in request.dashboards:
        dashboard = Dashboard(
            user_id=current_user.id,
            name=d.get("name", "Unbenannt"),
            layout={"widgets": d.get("widgets", [])}
        )
        db.add(dashboard)
        db.flush()
        synced.append({"id": dashboard.id, "name": dashboard.name})
    
    db.commit()
    return {"message": "Layouts synced", "count": len(synced)}

@router.get("/sync")
async def get_synced_layouts(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all synced layouts from server."""
    dashboards = db.query(Dashboard).filter(
        Dashboard.user_id == current_user.id
    ).all()
    return {"dashboards": [
        {
            "id": d.id,
            "name": d.name,
            "widgets": (d.layout or {}).get("widgets", []),
            "synced_at": d.created_at.isoformat() if d.created_at is not None else None
        }
        for d in dashboards
    ]}

# Templates

class TemplateResponse(BaseModel):
    id: str
    name: str
    description: str
    widgets: List[dict]

TEMPLATES = {
    "morgen": {
        "id": "morgen",
        "name": "Morgen",
        "description": "Wetter, Briefing und Kalender für deinen Start",
        "widgets": [
            {"widget_type": "weather", "size": "M", "config": {"location": "Berlin"}},
            {"widget_type": "tagesbriefing", "size": "M", "config": {}},
            {"widget_type": "calendar", "size": "M", "config": {}}
        ]
    },
    "fitness": {
        "id": "fitness",
        "name": "Fitness",
        "description": "Schritte, Proteine, Kalorien und Training",
        "widgets": [
            {"widget_type": "steps", "size": "M", "config": {}},
            {"widget_type": "protein_tracker", "size": "M", "config": {"goal": 150}},
            {"widget_type": "calorie_tracker", "size": "M", "config": {"goal": 2000}},
            {"widget_type": "active_minutes_tracker", "size": "M", "config": {"goal": 60}}
        ]
    },
    "wochenende": {
        "id": "wochenende",
        "name": "Wochenende",
        "description": "Parties, Filme und Restaurants in deiner Nähe",
        "widgets": [
            {"widget_type": "parties", "size": "M", "config": {}},
            {"widget_type": "weather", "size": "S", "config": {"location": "Berlin"}},
            {"widget_type": "calendar", "size": "M", "config": {}}
        ]
    }
}

@router.get("/templates")
async def list_templates():
    return {"templates": [TEMPLATES[k] for k in TEMPLATES]}

@router.get("/templates/{template_id}")
async def get_template(template_id: str):
    if template_id not in TEMPLATES:
        raise HTTPException(status_code=404, detail="Template not found")
    return TEMPLATES[template_id]

@router.post("/templates/{template_id}/apply")
async def apply_template(
    template_id: str,
    dashboard_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if template_id not in TEMPLATES:
        raise HTTPException(status_code=404, detail="Template not found")
    
    dashboard = db.query(Dashboard).filter(
        Dashboard.id == dashboard_id,
        Dashboard.user_id == current_user.id
    ).first()
    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")
    
    template = TEMPLATES[template_id]
    dashboard.layout = {"widgets": template["widgets"]}  # type: ignore[assignment]
    db.commit()
    db.refresh(dashboard)
    return {
        "id": dashboard.id,
        "name": dashboard.name,
        "layout": dashboard.layout,
        "message": f"Template '{template_id}' applied"
    }

# Share / Import

class ImportRequest(BaseModel):
    layout: dict

@router.post("/import")
async def import_layout(
    request: ImportRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Import a shared layout as a new dashboard."""
    name = request.layout.get("name", "Importiertes Dashboard")
    dashboard = Dashboard(
        user_id=current_user.id,
        name=name,
        layout=request.layout
    )
    db.add(dashboard)
    db.commit()
    db.refresh(dashboard)
    return {
        "id": dashboard.id,
        "name": dashboard.name,
        "layout": dashboard.layout,
        "message": "Layout imported"
    }
