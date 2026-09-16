from datetime import datetime
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class NotificationChannel(str, Enum):
    EMAIL = "email"
    SMS = "sms"
    SLACK = "slack"


class NotificationStatus(str, Enum):
    SENT = "sent"


class NotificationCreate(BaseModel):
    order_id: UUID
    recipient: str = Field(min_length=3, max_length=255)
    message: str = Field(min_length=1, max_length=1000)
    channel: NotificationChannel


class NotificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    order_id: UUID
    recipient: str
    message: str
    channel: NotificationChannel
    status: NotificationStatus
    created_at: datetime
