from datetime import datetime, timezone
from uuid import UUID, uuid4

from app.schemas import (
    NotificationCreate,
    NotificationResponse,
    NotificationStatus,
)

_notifications: dict[UUID, NotificationResponse] = {}


def create_notification(
    notification_data: NotificationCreate,
) -> NotificationResponse:
    notification = NotificationResponse(
        id=uuid4(),
        order_id=notification_data.order_id,
        recipient=notification_data.recipient,
        message=notification_data.message,
        channel=notification_data.channel,
        status=NotificationStatus.SENT,
        created_at=datetime.now(timezone.utc),
    )

    _notifications[notification.id] = notification
    return notification


def list_notifications() -> list[NotificationResponse]:
    return list(_notifications.values())


def get_notification(
    notification_id: UUID,
) -> NotificationResponse | None:
    return _notifications.get(notification_id)


def reset_notifications() -> None:
    _notifications.clear()
