from datetime import datetime, timezone
from uuid import UUID, uuid4

from app.schemas import UserCreate, UserResponse

_users: dict[UUID, UserResponse] = {}


def create_user(user_data: UserCreate) -> UserResponse:
    user = UserResponse(
        id=uuid4(),
        name=user_data.name,
        email=user_data.email,
        created_at=datetime.now(timezone.utc),
    )

    _users[user.id] = user
    return user


def list_users() -> list[UserResponse]:
    return list(_users.values())


def get_user(user_id: UUID) -> UserResponse | None:
    return _users.get(user_id)


def email_exists(email: str) -> bool:
    return any(str(user.email).lower() == email.lower() for user in _users.values())


def reset_users() -> None:
    _users.clear()
