from gpiozero import OutputDevice
from time import sleep

from config import (
    RELAY_LED_GPIO,
    RELAY_BASIL_PUMP_GPIO,
    RELAY_SUNFLOWER_PUMP_GPIO,
    RELAY_ACTIVE_HIGH,
)


led_relay = OutputDevice(
    RELAY_LED_GPIO,
    active_high=RELAY_ACTIVE_HIGH,
    initial_value=False
)

basil_pump_relay = OutputDevice(
    RELAY_BASIL_PUMP_GPIO,
    active_high=RELAY_ACTIVE_HIGH,
    initial_value=False
)

sunflower_pump_relay = OutputDevice(
    RELAY_SUNFLOWER_PUMP_GPIO,
    active_high=RELAY_ACTIVE_HIGH,
    initial_value=False
)


def set_led(on: bool):
    if on:
        print(f"[RELAY] LED ON: GPIO {RELAY_LED_GPIO}")
        led_relay.on()
    else:
        print(f"[RELAY] LED OFF: GPIO {RELAY_LED_GPIO}")
        led_relay.off()


def set_basil_pump(on: bool):
    if on:
        print(f"[RELAY] 바질 펌프 ON: GPIO {RELAY_BASIL_PUMP_GPIO}")
        basil_pump_relay.on()
    else:
        print(f"[RELAY] 바질 펌프 OFF: GPIO {RELAY_BASIL_PUMP_GPIO}")
        basil_pump_relay.off()


def set_sunflower_pump(on: bool):
    if on:
        print(f"[RELAY] 해바라기 펌프 ON: GPIO {RELAY_SUNFLOWER_PUMP_GPIO}")
        sunflower_pump_relay.on()
    else:
        print(f"[RELAY] 해바라기 펌프 OFF: GPIO {RELAY_SUNFLOWER_PUMP_GPIO}")
        sunflower_pump_relay.off()


def led_on():
    set_led(True)


def led_off():
    set_led(False)


def pump_for_gpio(gpio_pin: int, seconds: float):
    if gpio_pin == RELAY_BASIL_PUMP_GPIO:
        print(f"[RELAY] 바질 펌프 작동: GPIO {gpio_pin}, {seconds}초")
        try:
            set_basil_pump(True)
            sleep(seconds)
        finally:
            set_basil_pump(False)
        return

    if gpio_pin == RELAY_SUNFLOWER_PUMP_GPIO:
        print(f"[RELAY] 해바라기 펌프 작동: GPIO {gpio_pin}, {seconds}초")
        try:
            set_sunflower_pump(True)
            sleep(seconds)
        finally:
            set_sunflower_pump(False)
        return

    raise ValueError(f"등록되지 않은 펌프 GPIO입니다: {gpio_pin}")


def all_off():
    print("[RELAY] 전체 OFF")
    led_relay.off()
    basil_pump_relay.off()
    sunflower_pump_relay.off()


if __name__ == "__main__":
    try:
        all_off()

        input("LED 테스트: 엔터를 누르면 LED가 2초 켜집니다.")
        led_on()
        sleep(2)
        led_off()

        input("바질 펌프 테스트: 엔터를 누르면 바질 펌프가 1초 켜집니다.")
        pump_for_gpio(RELAY_BASIL_PUMP_GPIO, 1)

        input("해바라기 펌프 테스트: 엔터를 누르면 해바라기 펌프가 1초 켜집니다.")
        pump_for_gpio(RELAY_SUNFLOWER_PUMP_GPIO, 1)

    finally:
        all_off()
