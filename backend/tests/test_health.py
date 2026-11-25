import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_health_returns_ok():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"


def test_health_has_required_fields():
    response = client.get("/health")
    data = response.json()
    assert "version" in data
    assert "environment" in data
