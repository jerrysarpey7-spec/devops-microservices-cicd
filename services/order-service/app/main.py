import json
import logging
from datetime import datetime, timezone
from uuid import UUID

from fastapi import FastAPI, HTTPException, status

from app.repository import (
    create_order,
    get_order,
    list_orders,
    update_order_status,
)
from app.schemas import (
    OrderCreate,
    OrderResponse,
    OrderStatusUpdate,
)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

logger = logging.getLogger("order-service")

app = FastAPI(
    title="Order Service",
    description="Order management microservice.",
    version="1.0.0",
)


@app.get("/", tags=["system"])
def root() -> dict[str, str]:
    return {
        "service": "order-service",
        "status": "running",
        "version": app.version,
    }


@app.get("/health", tags=["system"])
def health_check() -> dict[str, str]:
    return {
        "status": "healthy",
        "service": "order-service",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/ready", tags=["system"])
def readiness_check() -> dict[str, str]:
    return {
        "status": "ready",
        "service": "order-service",
    }


@app.post(
    "/orders",
    response_model=OrderResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["orders"],
)
def add_order(order_data: OrderCreate) -> OrderResponse:
    order = create_order(order_data)

    logger.info(
        json.dumps(
            {
                "event": "order_created",
                "order_id": str(order.id),
                "user_id": str(order.user_id),
                "total_price": str(order.total_price),
            }
        )
    )

    return order


@app.get(
    "/orders",
    response_model=list[OrderResponse],
    tags=["orders"],
)
def get_orders() -> list[OrderResponse]:
    return list_orders()


@app.get(
    "/orders/{order_id}",
    response_model=OrderResponse,
    tags=["orders"],
)
def get_order_by_id(order_id: UUID) -> OrderResponse:
    order = get_order(order_id)

    if order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found.",
        )

    return order


@app.patch(
    "/orders/{order_id}/status",
    response_model=OrderResponse,
    tags=["orders"],
)
def change_order_status(
    order_id: UUID,
    status_update: OrderStatusUpdate,
) -> OrderResponse:
    order = update_order_status(
        order_id,
        status_update.status,
    )

    if order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found.",
        )

    logger.info(
        json.dumps(
            {
                "event": "order_status_updated",
                "order_id": str(order.id),
                "status": order.status.value,
            }
        )
    )

    return order
