import json
import logging
from datetime import datetime, timezone
from uuid import UUID

from fastapi import FastAPI, HTTPException, status

from app.repository import (
    create_payment,
    get_payment,
    list_payments,
    refund_payment,
)
from app.schemas import PaymentCreate, PaymentResponse

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

logger = logging.getLogger("payment-service")

app = FastAPI(
    title="Payment Service",
    description="Simulated payment processing microservice.",
    version="1.0.0",
)


@app.get("/", tags=["system"])
def root() -> dict[str, str]:
    return {
        "service": "payment-service",
        "status": "running",
        "version": app.version,
    }


@app.get("/health", tags=["system"])
def health_check() -> dict[str, str]:
    return {
        "status": "healthy",
        "service": "payment-service",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/ready", tags=["system"])
def readiness_check() -> dict[str, str]:
    return {
        "status": "ready",
        "service": "payment-service",
    }


@app.post(
    "/payments",
    response_model=PaymentResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["payments"],
)
def add_payment(payment_data: PaymentCreate) -> PaymentResponse:
    payment = create_payment(payment_data)

    logger.info(
        json.dumps(
            {
                "event": "payment_approved",
                "payment_id": str(payment.id),
                "order_id": str(payment.order_id),
                "transaction_id": payment.transaction_id,
            }
        )
    )

    return payment


@app.get(
    "/payments",
    response_model=list[PaymentResponse],
    tags=["payments"],
)
def get_payments() -> list[PaymentResponse]:
    return list_payments()


@app.get(
    "/payments/{payment_id}",
    response_model=PaymentResponse,
    tags=["payments"],
)
def get_payment_by_id(payment_id: UUID) -> PaymentResponse:
    payment = get_payment(payment_id)

    if payment is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment not found.",
        )

    return payment


@app.post(
    "/payments/{payment_id}/refund",
    response_model=PaymentResponse,
    tags=["payments"],
)
def refund_payment_by_id(payment_id: UUID) -> PaymentResponse:
    payment = refund_payment(payment_id)

    if payment is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment not found.",
        )

    logger.info(
        json.dumps(
            {
                "event": "payment_refunded",
                "payment_id": str(payment.id),
                "transaction_id": payment.transaction_id,
            }
        )
    )

    return payment
