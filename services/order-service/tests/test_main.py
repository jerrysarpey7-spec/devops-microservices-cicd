from decimal import Decimal

import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.repository import reset_orders

client = TestClient(app)

USER_ID = "11111111-1111-1111-1111-111111111111"


@pytest.fixture(autouse=True)
def clear_repository() -> None:
    reset_orders()


def create_test_order() -> dict:
    response = client.post(
        "/orders",
        json={
            "user_id": USER_ID,
            "product_name": "Cloud Engineering Book",
            "quantity": 2,
            "unit_price": "19.99",
        },
    )

    assert response.status_code == 201
    return response.json()


def test_health_check() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert response.json()["service"] == "order-service"


def test_create_order() -> None:
    body = create_test_order()

    assert body["user_id"] == USER_ID
    assert body["quantity"] == 2
    assert Decimal(str(body["total_price"])) == Decimal("39.98")
    assert body["status"] == "pending"


def test_list_orders() -> None:
    create_test_order()

    response = client.get("/orders")

    assert response.status_code == 200
    assert len(response.json()) == 1


def test_get_order_by_id() -> None:
    order = create_test_order()

    response = client.get(f"/orders/{order['id']}")

    assert response.status_code == 200
    assert response.json()["id"] == order["id"]


def test_missing_order_returns_404() -> None:
    response = client.get("/orders/00000000-0000-0000-0000-000000000000")

    assert response.status_code == 404


def test_update_order_status() -> None:
    order = create_test_order()

    response = client.patch(
        f"/orders/{order['id']}/status",
        json={"status": "processing"},
    )

    assert response.status_code == 200
    assert response.json()["status"] == "processing"


def test_invalid_quantity_returns_422() -> None:
    response = client.post(
        "/orders",
        json={
            "user_id": USER_ID,
            "product_name": "Cloud Engineering Book",
            "quantity": 0,
            "unit_price": "19.99",
        },
    )

    assert response.status_code == 422


def test_invalid_price_returns_422() -> None:
    response = client.post(
        "/orders",
        json={
            "user_id": USER_ID,
            "product_name": "Cloud Engineering Book",
            "quantity": 1,
            "unit_price": "-10.00",
        },
    )

    assert response.status_code == 422
