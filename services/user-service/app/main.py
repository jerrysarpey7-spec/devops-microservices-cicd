import json
import logging
from datetime import datetime, timezone
from uuid import UUID

from fastapi import FastAPI, HTTPException, status

from app.repository import create_user, email_exists, get_user, list_users
from app.schemas import UserCreate, UserResponse

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

logger = logging.getLogger("user-service")

app = FastAPI(
    title="User Service",
    description="User management microservice for the Kubernetes CI/CD platform.",
    version="1.0.0",
)


@app.get("/", tags=["system"])
def root() -> dict[str, str]:
    return {
        "service": "user-service",
        "status": "running",
        "version": app.version,
    }


@app.get("/health", tags=["system"])
def health_check() -> dict[str, str]:
    return {
        "status": "healthy",
        "service": "user-service",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/ready", tags=["system"])
def readiness_check() -> dict[str, str]:
    return {
        "status": "ready",
        "service": "user-service",
    }


@app.post(
    "/users",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["users"],
)
def add_user(user_data: UserCreate) -> UserResponse:
    if email_exists(str(user_data.email)):
        logger.warning(
            json.dumps(
                {
                    "event": "duplicate_user_rejected",
                    "email": str(user_data.email),
                }
            )
        )
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this email already exists.",
        )

    user = create_user(user_data)

    logger.info(
        json.dumps(
            {
                "event": "user_created",
                "user_id": str(user.id),
                "email": str(user.email),
            }
        )
    )

    return user


@app.get(
    "/users",
    response_model=list[UserResponse],
    tags=["users"],
)
def get_users() -> list[UserResponse]:
    return list_users()


@app.get(
    "/users/{user_id}",
    response_model=UserResponse,
    tags=["users"],
)
def get_user_by_id(user_id: UUID) -> UserResponse:
    user = get_user(user_id)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    return user
