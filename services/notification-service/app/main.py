import json
import logging
from datetime import datetime, timezone
from uuid import UUID

from fastapi import FastAPI, HTTPException, status

from app.repository import (
    create_notification,
    get_notification,
    list_notifications,
)
from app.schemas import NotificationCreate, NotificationResponse

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

logger = logging.getLogger("notification-service")

app = FastAPI(
    title="Notification Service",
    description="Simulated notification delivery microservice.",
    version="1.0.0",
)


@app.get("/", tags=["system"])
def root() -> dict[str, str]:
    return {
        "service": "notification-service",
        "status": "running",
        "version": app.version,
    }


@app.get("/health", tags=["system"])
def health_check() -> dict[str, str]:
    return {
        "status": "healthy",
        "service": "notification-service",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/ready", tags=["system"])
def readiness_check() -> dict[str, str]:
    return {
        "status": "ready",
        "service": "notification-service",
    }


@app.post(
    "/notifications",
    response_model=NotificationResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["notifications"],
)
def add_notification(
    notification_data: NotificationCreate,
) -> NotificationResponse:
    notification = create_notification(notification_data)

    logger.info(
        json.dumps(
            {
                "event": "notification_sent",
                "notification_id": str(notification.id),
                "order_id": str(notification.order_id),
                "channel": notification.channel.value,
            }
        )
    )

    return notification


@app.get(
    "/notifications",
    response_model=list[NotificationResponse],
    tags=["notifications"],
)
def get_notifications() -> list[NotificationResponse]:
    return list_notifications()


@app.get(
    "/notifications/{notification_id}",
    response_model=NotificationResponse,
    tags=["notifications"],
)
def get_notification_by_id(
    notification_id: UUID,
) -> NotificationResponse:
    notification = get_notification(notification_id)

    if notification is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found.",
        )

    return notification
