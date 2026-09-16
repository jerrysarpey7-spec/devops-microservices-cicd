from datetime import datetime
from decimal import Decimal
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class PaymentMethod(str, Enum):
    CARD = "card"
    PAYPAL = "paypal"
    BANK_TRANSFER = "bank_transfer"


class PaymentStatus(str, Enum):
    APPROVED = "approved"
    REFUNDED = "refunded"


class PaymentCreate(BaseModel):
    order_id: UUID
    amount: Decimal = Field(
        gt=Decimal(0),
        max_digits=10,
        decimal_places=2,
    )
    method: PaymentMethod


class PaymentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    order_id: UUID
    amount: Decimal
    method: PaymentMethod
    status: PaymentStatus
    transaction_id: str
    created_at: datetime
