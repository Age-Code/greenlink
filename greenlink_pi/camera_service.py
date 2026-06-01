# LEGACY: 직접 Picamera2 still 캡처 방식.
# 현재 active 경로는 stream_snapshot_service.py (MJPEG 프레임 추출 방식)이다.
# 이 파일은 현재 cron, systemd, camera_main.py에서 호출되지 않는다.
# 참조: camera_main.py → stream_snapshot_service.py → stream_server.py

from datetime import datetime
from pathlib import Path
import time

from picamera2 import Picamera2
from PIL import Image, ImageOps

from config import (
    IMAGE_DIR,
    IMAGE_ROTATE_DEGREES,
    IMAGE_FLIP_LEFT_RIGHT,
)


def fix_image_orientation(image_path: Path):
    """
    촬영된 이미지의 방향을 보정한다.

    IMAGE_ROTATE_DEGREES = 180이면 위아래 뒤집힌 사진을 정상 방향으로 돌린다.
    IMAGE_FLIP_LEFT_RIGHT = True이면 좌우 반전한다.
    """

    image = Image.open(image_path).convert("RGB")

    if IMAGE_ROTATE_DEGREES != 0:
        image = image.rotate(IMAGE_ROTATE_DEGREES, expand=True)

    if IMAGE_FLIP_LEFT_RIGHT:
        image = ImageOps.mirror(image)

    image.save(image_path, format="JPEG", quality=95)


def capture_image() -> Path:
    """
    Raspberry Pi Camera로 사진을 촬영하고 images 폴더에 저장한다.
    저장 후 이미지 방향 보정을 수행한다.
    반환값은 촬영된 이미지 파일 경로(Path)이다.
    """

    IMAGE_DIR.mkdir(parents=True, exist_ok=True)

    filename = IMAGE_DIR / f"sunflower_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"

    picam2 = Picamera2()

    try:
        camera_config = picam2.create_still_configuration()
        picam2.configure(camera_config)

        picam2.start()
        time.sleep(2)

        picam2.capture_file(str(filename))

        print(f"[CAMERA] 촬영 완료: {filename}")

        fix_image_orientation(filename)

        print(f"[CAMERA] 이미지 방향 보정 완료: {filename}")

        return filename

    finally:
        try:
            picam2.close()
        except Exception:
            pass
