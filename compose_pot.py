≈from pathlib import Path
from PIL import Image


def make_near_white_transparent(
    image: Image.Image,
    threshold: int = 245,
) -> Image.Image:
    """
    OpenAI 결과 이미지에 흰색 배경이 남아 있을 경우,
    거의 흰색에 가까운 픽셀을 투명하게 바꾼다.
    """
    image = image.convert("RGBA")
    pixels = image.load()

    width, height = image.size

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]

            if r >= threshold and g >= threshold and b >= threshold:
                pixels[x, y] = (255, 255, 255, 0)

    return image


def trim_transparent_area(image: Image.Image) -> Image.Image:
    """
    투명 영역을 잘라내고 실제 식물/화분 영역만 남긴다.
    """
    image = image.convert("RGBA")
    bbox = image.getbbox()

    if bbox is None:
        return image

    return image.crop(bbox)


def resize_by_height(image: Image.Image, target_height: int) -> Image.Image:
    ratio = target_height / image.height
    target_width = int(image.width * ratio)
    return image.resize((target_width, target_height), Image.LANCZOS)


def resize_by_width(image: Image.Image, target_width: int) -> Image.Image:
    ratio = target_width / image.width
    target_height = int(image.height * ratio)
    return image.resize((target_width, target_height), Image.LANCZOS)


def compose_plant_with_pot(
    plant_path: str | Path,
    pot_path: str | Path = "pot_base.png",
    output_path: str | Path = "outputs/final_composed.png",
) -> Path:
    """
    AI 식물 이미지와 화분 이미지를 자연스럽게 합성한다.

    핵심:
    - OpenAI 결과의 흰 배경을 투명화
    - 식물 실제 영역만 crop
    - 식물 아래쪽이 화분 입구 안쪽으로 들어가도록 위치 자동 배치
    """

    plant_path = Path(plant_path)
    pot_path = Path(pot_path)
    output_path = Path(output_path)

    if not plant_path.exists():
        raise FileNotFoundError(f"식물 이미지가 없습니다: {plant_path}")

    if not pot_path.exists():
        raise FileNotFoundError(f"화분 이미지가 없습니다: {pot_path}")

    output_path.parent.mkdir(parents=True, exist_ok=True)

    canvas_size = 1024
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (255, 255, 255, 0))

    # ==============================
    # 이미지 열기
    # ==============================
    plant = Image.open(plant_path).convert("RGBA")
    pot = Image.open(pot_path).convert("RGBA")

    # OpenAI 결과에 흰 배경이 있을 수 있으므로 제거
    plant = make_near_white_transparent(plant, threshold=245)

    # 실제 영역만 crop
    plant = trim_transparent_area(plant)
    pot = trim_transparent_area(pot)

    # ==============================
    # 화분 크기와 위치
    # ==============================
    pot_width = 500
    pot = resize_by_width(pot, pot_width)

    pot_x = (canvas_size - pot.width) // 2
    pot_y = 630

    # 화분 입구 기준점
    # 식물 줄기 아래가 이 근처로 들어오게 배치
    pot_mouth_y = pot_y + int(pot.height * 0.18)

    # ==============================
    # 식물 크기와 위치
    # ==============================
    plant_target_height = 520
    plant = resize_by_height(plant, plant_target_height)

    plant_x = (canvas_size - plant.width) // 2

    # 식물 아래쪽을 화분 입구보다 조금 아래로 넣음
    stem_insert_depth = 45
    plant_bottom_y = pot_mouth_y + stem_insert_depth
    plant_y = plant_bottom_y - plant.height

    # 화면 밖으로 너무 올라가면 보정
    if plant_y < 30:
        plant_y = 30

    # ==============================
    # 합성
    # ==============================
    # 식물 먼저
    canvas.alpha_composite(plant, (plant_x, plant_y))

    # 화분 나중
    # 이렇게 해야 줄기 아랫부분이 화분 뒤로 들어간 것처럼 보임
    canvas.alpha_composite(pot, (pot_x, pot_y))

    canvas.save(output_path, "PNG")

    print(f"[COMPOSE] 식물 크기: {plant.size}")
    print(f"[COMPOSE] 화분 크기: {pot.size}")
    print(f"[COMPOSE] 식물 위치: x={plant_x}, y={plant_y}")
    print(f"[COMPOSE] 화분 위치: x={pot_x}, y={pot_y}")
    print(f"[COMPOSE] 화분 합성 완료: {output_path}")

    return output_path
