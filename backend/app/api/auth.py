import bcrypt
from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException
from jose import jwt, JWTError
from pydantic import BaseModel
from app.config import settings

router = APIRouter()

# Mock users for demo (passwords are bcrypt hashes)
DEFAULT_HASH = bcrypt.hashpw(b"password123", bcrypt.gensalt(12)).decode()
users = {
    "test@example.com": {
        "email": "test@example.com",
        "password": DEFAULT_HASH,
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

def create_access_token(user_email: str) -> str:
    expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": user_email, "exp": expire}
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def get_user_from_token(token: str):
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email = payload.get("sub")
        return users.get(email)
    except JWTError:
        return None

@router.post("/login")
async def login(request: LoginRequest):
    user = users.get(request.email)
    if not user or not bcrypt.checkpw(request.password.encode(), user["password"].encode()):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(user["email"])
    return {"access_token": token, "user": {"email": user["email"], "name": user["name"]}}

@router.post("/register")
async def register(request: RegisterRequest):
    if request.email in users:
        raise HTTPException(status_code=400, detail="Email already registered")
    hashed = bcrypt.hashpw(request.password.encode(), bcrypt.gensalt(12)).decode()
    users[request.email] = {
        "email": request.email,
        "password": hashed,
        "name": request.name
    }
    return {"message": "User registered", "email": request.email}

@router.get("/me")
async def get_current_user():
    user = get_user_from_token("mock_token_123")
    if not user:
        user = users["test@example.com"]
    return {"email": user["email"], "name": user["name"]}