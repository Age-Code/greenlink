import requests

from config import AI_WORKER_URL


def trigger_ai_worker(
    plant_image_id: int,
    user_plant_id: int,
    image_url: str,
):
    """
    사진 업로드 성공 후 AI Worker에 변환 요청을 보낸다.

    AI Worker는 다음을 수행한다.
    1. imageUrl 다운로드
    2. AI 이미지 변환
    3. 최종 결과 S3 업로드
    4. 백엔드 ai_plant_image 저장
    """

    name = f"user_plant_{user_plant_id}_image_{plant_image_id}"

    payload = {
        "plantImageId": plant_image_id,
        "userPlantId": user_plant_id,
        "imageUrl": image_url,
        "name": name,
    }

    print("[AI_TRIGGER] AI Worker 요청 시작")
    print(f"[AI_TRIGGER] URL: {AI_WORKER_URL}")
    print(f"[AI_TRIGGER] payload: {payload}")

    response = requests.post(
        AI_WORKER_URL,
        json=payload,
        timeout=10,
    )

    print(f"[AI_TRIGGER] 응답 코드: {response.status_code}")
    print(f"[AI_TRIGGER] 응답 본문: {response.text}")

    response.raise_for_status()

    return response.json()
