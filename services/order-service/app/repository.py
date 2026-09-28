from datetime import datetime, timezone
from decimal import Decimal
from uuid import UUID, uuid4

from app.schemas import OrderCreate, OrderResponse, OrderStatus

_orders: dict[UUID, OrderResponse] = {}


def create_order(order_data: OrderCreate) -> OrderResponse:
    total_price = (order_data.unit_price * order_data.quantity).quantize(
        Decimal("0.01")
    )

    order = OrderResponse(
        id=uuid4(),
        user_id=order_data.user_id,
        product_name=order_data.product_name,
        quantity=order_data.quantity,
        unit_price=order_data.unit_price,
        total_price=total_price,
        status=OrderStatus.PENDING,
        created_at=datetime.now(timezone.utc),
    )

    _orders[order.id] = order
    return order


def list_orders() -> list[OrderResponse]:
    return list(_orders.values())


def get_order(order_id: UUID) -> OrderResponse | None:
    return _orders.get(order_id)


def update_order_status(
    order_id: UUID,
    new_status: OrderStatus,
) -> OrderResponse | None:
    order = _orders.get(order_id)

    if order is None:
        return None

    updated_order = order.model_copy(
        update={"status": new_status},
    )

    _orders[order_id] = updated_order
    return updated_order


def reset_orders() -> None:
    _orders.clear()
