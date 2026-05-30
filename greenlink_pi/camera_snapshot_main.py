from datetime import datetime
from pathlib import Path
import requests

from config import IMAGE_DIR, SUNFLOWER_USER_PLANT_ID
from uploader import upload_image_and_delete_if_success


SNAPSHOT_URL = "http://localhost:8000/snapshot.jpg"


def download_snapshot() -> Path:
    IMAGE_DIR.mkdir(parents=True, exist_ok=True)

    filename = IMAGE_DIR / f"sunflower_snapshot_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"

    response = requests.get(SNAPSHOT_URL, timeout=10)
    response.raise_for_status()

    with open(filename, "wb") as f:
        f.write(response.content)

    print(f"[SNAPSHOT] 저장 완료: {filename}")
    return filename


def main():
    print("[SNAPSHOT] 실시간 카메라 프레임 저장 시작")

    image_path = download_snapshot()

    print("[SNAPSHOT] 서버 업로드 시작")

    result = upload_image_and_delete_if_success(
        image_path=image_path,
        user_plant_id=SUNFLOWER_USER_PLANT_ID
    )

    print("[SNAPSHOT] 전체 처리 완료")
    print(f"[SNAPSHOT] 결과: {result}")


if __name__ == "__main__":
    main()
