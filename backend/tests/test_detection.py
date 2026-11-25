import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_detect_plant_requires_auth():
    response = client.post("/api/v1/detect/plant")
    assert response.status_code == 401


def test_detect_animal_requires_auth():
    response = client.post("/api/v1/detect/animal")
    assert response.status_code == 401
