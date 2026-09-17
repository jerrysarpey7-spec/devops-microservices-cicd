from decimal import Decimal

import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.repository import reset_payments

client = TestClient(app)

ORDER_ID = "22222222-2222-2222-2222-222222222222"


@pytest.fixture(autouse=True)
def clear_repository() -> None:
    reset_payments()


def create_test_payment() -> dict:
    response = client.post(
        "/payments",
        json={
            "order_id": ORDER_ID,
            "amount": "39.98",
            "method": "card",
        },
    )

    assert response.status_code == 201
    return response.json()


def test_health_check() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert response.json()["service"] == "payment-service"


def test_create_payment() -> None:
    body = create_test_payment()

    assert body["order_id"] == ORDER_ID
    assert Decimal(str(body["amount"])) == Decimal("39.98")
    assert body["method"] == "card"
    assert body["status"] == "approved"
    assert body["transaction_id"].startswith("txn_")


def test_list_payments() -> None:
    create_test_payment()

    response = client.get("/payments")

    assert response.status_code == 200
    assert len(response.json()) == 1


def test_get_payment_by_id() -> None:
    payment = create_test_payment()

    response = client.get(f"/payments/{payment['id']}")

    assert response.status_code == 200
    assert response.json()["id"] == payment["id"]


def test_missing_payment_returns_404() -> None:
    response = client.get("/payments/00000000-0000-0000-0000-000000000000")

    assert response.status_code == 404


def test_refund_payment() -> None:
    payment = create_test_payment()

    response = client.post(f"/payments/{payment['id']}/refund")

    assert response.status_code == 200
    assert response.json()["status"] == "refunded"


def test_refund_missing_payment_returns_404() -> None:
    response = client.post("/payments/00000000-0000-0000-0000-000000000000/refund")

    assert response.status_code == 404


def test_invalid_amount_returns_422() -> None:
    response = client.post(
        "/payments",
        json={
            "order_id": ORDER_ID,
            "amount": "0.00",
            "method": "card",
        },
    )

    assert response.status_code == 422
