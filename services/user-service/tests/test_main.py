import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.repository import reset_users

client = TestClient(app)


@pytest.fixture(autouse=True)
def clear_repository() -> None:
    reset_users()


def test_health_check() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert response.json()["service"] == "user-service"


def test_readiness_check() -> None:
    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json() == {
        "status": "ready",
        "service": "user-service",
    }


def test_create_user() -> None:
    response = client.post(
        "/users",
        json={
            "name": "Jerry Sarpey",
            "email": "jerry@example.com",
        },
    )

    assert response.status_code == 201

    body = response.json()

    assert body["name"] == "Jerry Sarpey"
    assert body["email"] == "jerry@example.com"
    assert "id" in body
    assert "created_at" in body


def test_list_users() -> None:
    client.post(
        "/users",
        json={
            "name": "Jerry Sarpey",
            "email": "jerry@example.com",
        },
    )

    response = client.get("/users")

    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["email"] == "jerry@example.com"


def test_get_user_by_id() -> None:
    create_response = client.post(
        "/users",
        json={
            "name": "Jerry Sarpey",
            "email": "jerry@example.com",
        },
    )

    user_id = create_response.json()["id"]
    response = client.get(f"/users/{user_id}")

    assert response.status_code == 200
    assert response.json()["id"] == user_id


def test_missing_user_returns_404() -> None:
    response = client.get("/users/00000000-0000-0000-0000-000000000000")

    assert response.status_code == 404
    assert response.json()["detail"] == "User not found."


def test_duplicate_email_returns_409() -> None:
    payload = {
        "name": "Jerry Sarpey",
        "email": "jerry@example.com",
    }

    first_response = client.post("/users", json=payload)
    second_response = client.post("/users", json=payload)

    assert first_response.status_code == 201
    assert second_response.status_code == 409


def test_invalid_email_returns_422() -> None:
    response = client.post(
        "/users",
        json={
            "name": "Jerry Sarpey",
            "email": "invalid-email",
        },
    )

    assert response.status_code == 422
