from datetime import datetime
from app.db.mongodb import db
from bson import ObjectId

def get_level(score: int):
    if score >= 80:
        return "Sangat Baik"
    elif score >= 60:
        return "Baik"
    elif score >= 40:
        return "Sedang"
    elif score >= 20:
        return "Kurang"
    else:
        return "Buruk"


def create_assessment(user_id: str, data):

    # ==========================
    # SKOR PHQ / GAD / STRESS
    # ==========================

    phq_score = sum(data.phq_answers)
    gad_score = sum(data.gad_answers)
    stress_score = sum(data.stress_answers)

    mental_raw = (
        phq_score +
        gad_score +
        stress_score
    )

    # Maksimum 15 pertanyaan × 4 = 60

    mental_percentage = 100 - (
        (mental_raw / 60) * 100
    )

    # ==========================
    # AKTIVITAS HARIAN
    # ==========================

    sleep_score = min(
        (data.sleep_hours / 8) * 100,
        100
    )

    quality_score = (
        data.sleep_quality / 4
    ) * 100

    activity_score = (
        data.physical_activity / 4
    ) * 100

    social_score = (
        data.social_interaction / 4
    ) * 100

    productivity_score = (
        data.productivity / 4
    ) * 100

    lifestyle_score = (
        sleep_score +
        quality_score +
        activity_score +
        social_score +
        productivity_score
    ) / 5

    # ==========================
    # SKOR AKHIR
    # ==========================

    final_score = round(
        (mental_percentage * 0.7) +
        (lifestyle_score * 0.3)
    )

    assessment = {
        "user_id": user_id,

        "phq_answers": data.phq_answers,
        "gad_answers": data.gad_answers,
        "stress_answers": data.stress_answers,

        "sleep_hours": data.sleep_hours,
        "sleep_quality": data.sleep_quality,
        "physical_activity": data.physical_activity,
        "social_interaction": data.social_interaction,
        "productivity": data.productivity,

        "phq_score": phq_score,
        "gad_score": gad_score,
        "stress_score": stress_score,

        "mental_percentage": round(
            mental_percentage
        ),

        "lifestyle_score": round(
            lifestyle_score
        ),

        "final_score": final_score,

        "level": get_level(
            final_score
        ),

        "created_at": datetime.utcnow(),
    }

    db.assessments.insert_one(
        assessment
    )

    return {
        "phq_score": phq_score,
        "gad_score": gad_score,
        "stress_score": stress_score,

        "mental_percentage":
            round(mental_percentage),

        "lifestyle_score":
            round(lifestyle_score),

        "final_score":
            final_score,

        "level":
            get_level(final_score),

        "sleep_hours": data.sleep_hours,
        "social_interaction": data.social_interaction,
        "productivity": data.productivity,
    }

def get_assessment_history(user_id: str):

    assessments = list(
        db.assessments.find(
            {"user_id": user_id}
        ).sort(
            "created_at",
            -1
        )
    )

    result = []

    for item in assessments:
        result.append({
            "id": str(item["_id"]),

            "created_at":
                item["created_at"],

            "phq_score":
                item["phq_score"],

            "gad_score":
                item["gad_score"],

            "stress_score":
                item["stress_score"],

            "mental_percentage":
                item.get(
                    "mental_percentage",
                    0
                ),

            "lifestyle_score":
                item.get(
                    "lifestyle_score",
                    0
                ),

            "final_score":
                item.get(
                    "final_score",
                    0
                ),

            "level":
                item.get(
                    "level",
                    "-"
                ),

            "sleep_hours":
                item.get(
                    "sleep_hours",
                    0
                ),

            "social_interaction":
                item.get(
                    "social_interaction",
                    0
                ),

            "productivity":
                item.get(
                    "productivity",
                    0
                ),
        })

    return result

def get_assessment_detail(
    assessment_id: str
):
    item = db.assessments.find_one(
        {
            "_id": ObjectId(
                assessment_id
            )
        }
    )

    if not item:
        return None

    return {
        "id": str(item["_id"]),

        "created_at":
            item["created_at"],

        "phq_score":
            item["phq_score"],

        "gad_score":
            item["gad_score"],

        "stress_score":
            item["stress_score"],

        "mental_percentage":
            item["mental_percentage"],

        "lifestyle_score":
            item["lifestyle_score"],

        "final_score":
            item["final_score"],

        "level":
            item["level"],

        "sleep_hours":
            item["sleep_hours"],

        "social_interaction":
            item["social_interaction"],

        "productivity":
            item["productivity"],
    }