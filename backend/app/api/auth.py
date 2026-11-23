from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

# Mock users for demo
users = {
    "test@example.com": {
        "email": "test@example.com",
        "password": "password123",
        "name": "Test User"
    }
}

class LoginRequest(BaseModel):
    email: str
    password: str

class RegisterRequest(BaseModel):
    email: str
    password: str
    name: str

@router.post("/login")
async def login(request: LoginRequest):
    user = users.get(request.email)
    if not user or user["password"] != request.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return {"access_token": "mock_token_123", "user": {"email": user["email"], "name": user["name"]}}

@router.post("/register")
async def register(request: RegisterRequest):
    if request.email in users:
        raise HTTPException(status_code=400, detail="Email already registered")
    users[request.email] = {
        "email": request.email,
        "password": request.password,
        "name": request.name
    }
    return {"message": "User registered", "email": request.email}

@router.get("/me")
async def get_current_user():
    # In real implementation, this would use token auth
    return {"email": "test@example.com", "name": "Test User"}
