from pathlib import Path
from PIL import Image
from rembg import remove, new_session
import io
import numpy as np


AI_BG_REMOVE_MODEL = "u2netp"


def clean_transparent_pixels(rgba: Image.Image) -> Image.Image:
    """
    alpha가 0인 영역의 RGB 값을 0으로 정리한다.
    앱에서 합성할 때 흰색/회색 테두리가 남는 것을 줄이기 위한 후처리.
    """
    rgba_np = np.array(rgba, dtype=np.uint8)

    alpha = rgba_np[..., 3]
    transparent_mask = alpha == 0

    rgba_np[..., 0][transparent_mask] = 0
    rgba_np[..., 1][transparent_mask] = 0
    rgba_np[..., 2][transparent_mask] = 0

    return Image.fromarray(rgba_np, mode="RGBA")


def remove_ai_background(
    ai_image_path: Path,
    output_path: Path,
    session=None,
) -> Path:
    """
    OpenAI가 만든 AI raw 이미지 자체에 배경제거를 다시 적용한다.
    원본 마스크를 사용하지 않는다.
    """

    if not ai_image_path.exists():
        raise FileNotFoundError(f"AI 이미지가 없습니다: {ai_image_path}")

    if session is None:
        session = new_session(AI_BG_REMOVE_MODEL)

    input_bytes = ai_image_path.read_bytes()

    output_bytes = remove(
        input_bytes,
        session=session,
        force_return_bytes=True,
    )

    rgba = Image.open(io.BytesIO(output_bytes)).convert("RGBA")
    rgba = clean_transparent_pixels(rgba)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    rgba.save(output_path, format="PNG")

    return output_path
