from pydantic import BaseModel, Field


class AssessmentCreate(BaseModel):
    # PHQ
    phq_answers: list[int] = Field(
        ...,
        min_length=5,
        max_length=5
    )

    # GAD
    gad_answers: list[int] = Field(
        ...,
        min_length=5,
        max_length=5
    )

    # Stress / DASS
    stress_answers: list[int] = Field(
        ...,
        min_length=5,
        max_length=5
    )

    # Aktivitas Harian
    sleep_hours: float
    sleep_quality: int
    physical_activity: int
    social_interaction: int
    productivity: int


class AssessmentResponse(BaseModel):
    # Score mentah
    phq_score: int
    gad_score: int
    stress_score: int

    # Score hasil perhitungan
    mental_percentage: int
    lifestyle_score: int
    final_score: int

    # Kategori akhir
    level: str

    # Aktivitas harian
    sleep_hours: float
    social_interaction: int
    productivity: int