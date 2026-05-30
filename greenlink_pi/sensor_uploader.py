from datetime import datetime
import requests

from config import SERVER_ENVIRONMENT_URL, DEVICE_KEY


def upload_sensor_data(sensor_data: dict):
    payload = {
        "temperature": sensor_data.get("temperatureC"),
        "humidity": sensor_data.get("humidityPercent"),
        "light": sensor_data.get("lightLux"),
        "measuredAt": datetime.now().isoformat(timespec="seconds"),
    }

    headers = {
        "X-DEVICE-KEY": DEVICE_KEY,
        "Content-Type": "application/json",
    }

    response = requests.post(
        SERVER_ENVIRONMENT_URL,
        json=payload,
        headers=headers,
        timeout=10,
    )

    return response


def upload_sensor_data_safe(sensor_data: dict):
    try:
        response = upload_sensor_data(sensor_data)

    except Exception as e:
        print(f"[SENSOR_UPLOAD] 센서 업로드 요청 실패: {e}")
        return False, None

    print(f"[SENSOR_UPLOAD] 응답 코드: {response.status_code}")
    print(f"[SENSOR_UPLOAD] 응답 본문: {response.text}")

    if response.status_code in (200, 201):
        try:
            body = response.json()

            if body.get("success") is True:
                print("[SENSOR_UPLOAD] 센서 업로드 성공")
                return True, body

            print(f"[SENSOR_UPLOAD] 서버 응답 success=false: {body.get('message')}")
            return False, body

        except Exception as e:
            print(f"[SENSOR_UPLOAD] 응답 JSON 해석 실패: {e}")
            return False, None

    print("[SENSOR_UPLOAD] 센서 업로드 실패")
    return False, None
