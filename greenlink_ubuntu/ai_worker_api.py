from datetime import datetime

from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel

from process_one import process_one


app = FastAPI(title="GreenLink AI Worker")


class ProcessRequest(BaseModel):
    plantImageId: int
    userPlantId: int | None = None
    imageUrl: str
    name: str | None = None


@app.get("/health")
def health_check():
    return {
        "success": True,
        "message": "GreenLink AI Worker is running",
    }


def make_job_name(request: ProcessRequest) -> str:
    name = request.name

    if name is not None and name.strip() != "":
        return name

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    if request.userPlantId is not None:
        return f"user_plant_{request.userPlantId}_image_{request.plantImageId}_{timestamp}"

    return f"plant_image_{request.plantImageId}_{timestamp}"


def run_ai_job(
    image_url: str,
    name: str,
    plant_image_id: int,
):
    try:
        print("===== GreenLink AI Background Job Start =====")
        print(f"[AI_WORKER] plantImageId: {plant_image_id}")
        print(f"[AI_WORKER] imageUrl: {image_url}")
        print(f"[AI_WORKER] name: {name}")

        result = process_one(
            image_url=image_url,
            name=name,
            plant_image_id=plant_image_id,
        )

        print("===== GreenLink AI Background Job Done =====")
        print(f"[AI_WORKER] result: {result}")

    except Exception as e:
        print("===== GreenLink AI Background Job Failed =====")
        print(f"[AI_WORKER] error: {e}")


@app.post("/process")
def process_image(
    request: ProcessRequest,
    background_tasks: BackgroundTasks,
):
    name = make_job_name(request)

    background_tasks.add_task(
        run_ai_job,
        request.imageUrl,
        name,
        request.plantImageId,
    )

    return {
        "success": True,
        "message": "AI processing started",
        "data": {
            "plantImageId": request.plantImageId,
            "userPlantId": request.userPlantId,
            "imageUrl": request.imageUrl,
            "name": name,
            "status": "PROCESSING",
        },
    }
