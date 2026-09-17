from datetime import datetime, timezone
from uuid import UUID, uuid4

from app.schemas import (
    PaymentCreate,
    PaymentResponse,
    PaymentStatus,
)

_payments: dict[UUID, PaymentResponse] = {}


def create_payment(payment_data: PaymentCreate) -> PaymentResponse:
    payment = PaymentResponse(
        id=uuid4(),
        order_id=payment_data.order_id,
        amount=payment_data.amount,
        method=payment_data.method,
        status=PaymentStatus.APPROVED,
        transaction_id=f"txn_{uuid4().hex}",
        created_at=datetime.now(timezone.utc),
    )

    _payments[payment.id] = payment
    return payment


def list_payments() -> list[PaymentResponse]:
    return list(_payments.values())


def get_payment(payment_id: UUID) -> PaymentResponse | None:
    return _payments.get(payment_id)


def refund_payment(payment_id: UUID) -> PaymentResponse | None:
    payment = _payments.get(payment_id)

    if payment is None:
        return None

    refunded_payment = payment.model_copy(
        update={"status": PaymentStatus.REFUNDED},
    )

    _payments[payment_id] = refunded_payment
    return refunded_payment


def reset_payments() -> None:
    _payments.clear()
