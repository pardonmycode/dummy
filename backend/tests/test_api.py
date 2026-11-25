"""Tests for basic API endpoint responses."""
import pytest
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


class TestRootEndpoint:
    """Tests for the root endpoint."""

    def test_root_returns_200(self):
        """Root endpoint should return 200 OK."""
        response = client.get("/")
        assert response.status_code == 200

    def test_root_returns_json(self):
        """Root endpoint should return JSON."""
        response = client.get("/")
        assert "application/json" in response.headers["content-type"]

    def test_root_contains_message(self):
        """Root endpoint should contain the expected message."""
        response = client.get("/")
        data = response.json()
        assert "message" in data
        assert "Widgetly" in data["message"]


class TestHealthEndpoint:
    """Tests for the health check endpoint."""

    def test_health_returns_200(self):
        """Health endpoint should return 200 OK."""
        response = client.get("/health")
        assert response.status_code == 200

    def test_health_returns_json(self):
        """Health endpoint should return JSON."""
        response = client.get("/health")
        assert "application/json" in response.headers["content-type"]

    def test_health_status_ok(self):
        """Health endpoint should report status ok."""
        response = client.get("/health")
        data = response.json()
        assert data["status"] == "ok"


class TestAPIPrefix:
    """Tests for API prefix routing."""

    def test_auth_routes_use_api_prefix(self):
        """Auth routes should be prefixed with /api/auth."""
        # Test that known API prefix routes exist
        response = client.post("/api/auth/login", json={"email": "test@test.com", "password": "test"})
        # Should return 401 (invalid credentials), not 404
        assert response.status_code != 404