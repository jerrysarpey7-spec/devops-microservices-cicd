import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.repository import reset_notifications

client = TestClient(app)

ORDER_ID = "33333333-3333-3333-3333-333333333333"


@pytest.fixture(autouse=True)
def clear_repository() -> None:
    reset_notifications()


def create_test_notification() -> dict:
    response = client.post(
        "/notifications",
        json={
            "order_id": ORDER_ID,
            "recipient": "portfolio@example.com",
            "message": "Your order was successfully processed.",
            "channel": "email",
        },
    )

    assert response.status_code == 201
    return response.json()


def test_health_check() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert response.json()["service"] == "notification-service"


def test_readiness_check() -> None:
    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json()["status"] == "ready"


def test_create_notification() -> None:
    body = create_test_notification()

    assert body["order_id"] == ORDER_ID
    assert body["recipient"] == "portfolio@example.com"
    assert body["channel"] == "email"
    assert body["status"] == "sent"


def test_list_notifications() -> None:
    create_test_notification()

    response = client.get("/notifications")

    assert response.status_code == 200
    assert len(response.json()) == 1


def test_get_notification_by_id() -> None:
    notification = create_test_notification()

    response = client.get(f"/notifications/{notification['id']}")

    assert response.status_code == 200
    assert response.json()["id"] == notification["id"]


def test_missing_notification_returns_404() -> None:
    response = client.get("/notifications/00000000-0000-0000-0000-000000000000")

    assert response.status_code == 404


def test_empty_message_returns_422() -> None:
    response = client.post(
        "/notifications",
        json={
            "order_id": ORDER_ID,
            "recipient": "portfolio@example.com",
            "message": "",
            "channel": "email",
        },
    )

    assert response.status_code == 422


def test_invalid_channel_returns_422() -> None:
    response = client.post(
        "/notifications",
        json={
            "order_id": ORDER_ID,
            "recipient": "portfolio@example.com",
            "message": "Order completed.",
            "channel": "carrier_pigeon",
        },
    )

    assert response.status_code == 422
