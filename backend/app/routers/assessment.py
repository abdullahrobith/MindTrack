from fastapi import APIRouter, Depends

from app.dependencies.auth import get_current_user
from app.schemas.assessment import (
    AssessmentCreate,
    AssessmentResponse,
)
from app.services.assessment_service import create_assessment
from app.services.assessment_service import (
    create_assessment,
    get_assessment_history,
    get_assessment_detail,
)

router = APIRouter(
    prefix="/assessment",
    tags=["Assessment"],
)


@router.post(
    "/submit",
    response_model=AssessmentResponse,
)
def submit_assessment(
    data: AssessmentCreate,
    current_user: dict = Depends(get_current_user),
):
    return create_assessment(
        str(current_user["_id"]),
        data,
    )

@router.get("/history")
def history(
    current_user: dict = Depends(
        get_current_user
    ),
):
    return get_assessment_history(
        str(current_user["_id"])
    )

@router.get("/detail/{assessment_id}")
def detail(
    assessment_id: str,
    current_user: dict = Depends(
        get_current_user
    ),
):
    return get_assessment_detail(
        assessment_id
    )