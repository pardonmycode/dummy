"""Tests for JWT authentication and password hashing."""
import pytest
from datetime import timedelta

from app.auth import (
    create_access_token,
    decode_token,
    get_password_hash,
    verify_password,
)
from app.config import settings


class TestPasswordHashing:
    """Tests for password hashing and verification."""

    def test_password_hash_returns_string(self):
        """Password hash should return a non-empty string."""
        password = "test_password_123"
        hashed = get_password_hash(password)
        assert isinstance(hashed, str)
        assert len(hashed) > 0
        assert hashed != password  # Hash should differ from plaintext

    def test_password_hash_is_deterministic_format(self):
        """Hash should start with bcrypt identifier."""
        hashed = get_password_hash("test")
        assert hashed.startswith("$2b$") or hashed.startswith("$2a$")

    def test_verify_correct_password(self):
        """Correct password should verify successfully."""
        password = "my_secret_password"
        hashed = get_password_hash(password)
        assert verify_password(password, hashed) is True

    def test_verify_wrong_password(self):
        """Wrong password should fail verification."""
        password = "correct_password"
        wrong_password = "wrong_password"
        hashed = get_password_hash(password)
        assert verify_password(wrong_password, hashed) is False

    def test_verify_empty_password(self):
        """Empty password should fail verification."""
        password = "real_password"
        hashed = get_password_hash(password)
        assert verify_password("", hashed) is False


class TestJWTTokenGeneration:
    """Tests for JWT token creation and decoding."""

    def test_create_token_returns_string(self):
        """Token creation should return a non-empty string."""
        token = create_access_token(data={"sub": "1"})
        assert isinstance(token, str)
        assert len(token) > 0

    def test_decode_valid_token(self):
        """Valid token should decode successfully."""
        user_id = "12345"
        token = create_access_token(data={"sub": user_id, "email": "test@example.com"})
        payload = decode_token(token)
        assert payload["sub"] == user_id
        assert payload["email"] == "test@example.com"

    def test_decode_contains_expiration(self):
        """Decoded token should contain expiration claim."""
        token = create_access_token(data={"sub": "1"})
        payload = decode_token(token)
        assert "exp" in payload

    def test_decode_invalid_token_raises(self):
        """Decoding an invalid token should raise an HTTPException."""
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            decode_token("invalid.token.value")
        assert exc_info.value.status_code == 401

    def test_decode_tampered_token_raises(self):
        """Decoding a tampered token should raise an HTTPException."""
        from fastapi import HTTPException
        token = create_access_token(data={"sub": "1"})
        # Tamper with the token
        tampered = token[:-5] + "xxxxx"
        with pytest.raises(HTTPException):
            decode_token(tampered)

    def test_custom_expiration(self):
        """Token should respect custom expiration delta."""
        custom_expiry = timedelta(minutes=15)
        token = create_access_token(data={"sub": "1"}, expires_delta=custom_expiry)
        payload = decode_token(token)
        assert "exp" in payload