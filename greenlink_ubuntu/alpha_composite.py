from pathlib import Path
from PIL import Image


def apply_alpha_mask_from_source(
    source_transparent_path: Path,
    ai_image_path: Path,
    output_path: Path,
):
    """
    source_transparent_path의 alpha 채널을 가져와서
    ai_image_path에 덮어씌워 최종 투명 PNG를 만든다.
    """

    if not source_transparent_path.exists():
        raise FileNotFoundError(f"소스 transparent 이미지가 없습니다: {source_transparent_path}")

    if not ai_image_path.exists():
        raise FileNotFoundError(f"AI 결과 이미지가 없습니다: {ai_image_path}")

    src_rgba = Image.open(source_transparent_path).convert("RGBA")
    ai_rgba = Image.open(ai_image_path).convert("RGBA")

    # OpenAI 결과 크기가 다를 수 있으니 source 크기에 맞춤
    if ai_rgba.size != src_rgba.size:
        ai_rgba = ai_rgba.resize(src_rgba.size, Image.LANCZOS)

    src_alpha = src_rgba.getchannel("A")

    ai_rgba.putalpha(src_alpha)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    ai_rgba.save(output_path, format="PNG")

    return output_path
