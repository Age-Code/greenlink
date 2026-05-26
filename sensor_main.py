from sensor_service import read_all_sensors, cleanup_sensors
from sensor_uploader import upload_sensor_data_safe


def print_sensor_data(sensor_data: dict):
    print("===== Sensor Data =====")
    print(f"lightLux: {sensor_data.get('lightLux')}")
    print(f"temperatureC: {sensor_data.get('temperatureC')}")
    print(f"humidityPercent: {sensor_data.get('humidityPercent')}")
    print("=======================")


def main():
    try:
        sensor_data = read_all_sensors()

        print_sensor_data(sensor_data)

        print("센서 업로드 시작")
        upload_sensor_data_safe(sensor_data)

    finally:
        cleanup_sensors()


if __name__ == "__main__":
    main()
