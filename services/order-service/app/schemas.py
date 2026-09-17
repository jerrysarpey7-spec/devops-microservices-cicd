from datetime import datetime
from decimal import Decimal
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class OrderStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class OrderCreate(BaseModel):
    user_id: UUID
    product_name: str = Field(min_length=2, max_length=200)
    quantity: int = Field(ge=1, le=100)
    unit_price: Decimal = Field(
        gt=Decimal(0),
        max_digits=10,
        decimal_places=2,
    )


class OrderStatusUpdate(BaseModel):
    status: OrderStatus


class OrderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    product_name: str
    quantity: int
    unit_price: Decimal
    total_price: Decimal
    status: OrderStatus
    created_at: datetime
