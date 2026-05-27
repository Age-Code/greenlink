#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <math.h>

// =====================================================
// 1. Wi-Fi 설정
// =====================================================

const char* WIFI_SSID = "greenlink";
const char* WIFI_PASSWORD = "greenlink0415";


// =====================================================
// 2. 서버 및 기기 설정
// =====================================================

const char* SERVER_URL = "http://54.180.203.50:8080/api/iot/esp/soil-moisture";

// 해바라기용 ESP 키
// const char* DEVICE_KEY = "ESP-SUNFLOWER-001";

// 바질용으로 사용할 때는 위 해바라기 키를 주석 처리하고 아래를 사용
const char* DEVICE_KEY = "ESP-BASIL-001";


// =====================================================
// 3. 핀 설정
// =====================================================

const int SOIL_SENSOR_PIN = 34;


// =====================================================
// 4. 센서 보정값 설정
// =====================================================
//
// 토양수분센서는 보통:
// raw 값이 클수록 건조
// raw 값이 작을수록 습함
//
// 계산식:
// percent = (DRY_RAW - raw) / (DRY_RAW - WET_RAW) * 100
//
// 주의:
// 공기 중 raw 값은 센서 정상 확인용이고,
// 실제 계산에는 "마른 흙 raw"와 "충분히 젖은 흙 raw"를 사용한다.
//
// 해바라기 센서 기준 측정값:
// 공기 중: 2783, 2781
// 마른 흙: 2213, 2224
// 젖은 흙: 1711, 1710
// 물 더 줌: 1438, 1461
//
// 실제 DB에 최근 들어온 raw 값이 1420~1423이었으므로,
// WET_RAW = 1710으로 두면 현재 raw가 WET_RAW보다 작아져서
// percent가 100%로 계속 잘리는 문제가 생긴다.
//
// 그래서 현재 운영 기준에서는 충분히 젖은 상태를 1400 근처로 잡는다.

const int SUNFLOWER_DRY_RAW = 1700;
const int SUNFLOWER_WET_RAW = 1300;

// 바질은 나중에 바질 센서로 따로 보정해야 함.
// 지금은 임시값으로 해바라기와 동일하게 둔다.
const int BASIL_DRY_RAW = 1700;
const int BASIL_WET_RAW = 1300;

// 현재 이 코드는 해바라기 ESP용
// const int DRY_RAW = SUNFLOWER_DRY_RAW;
// const int WET_RAW = SUNFLOWER_WET_RAW;

// 바질 ESP에 넣을 때는 위 두 줄을 주석 처리하고 아래 두 줄 사용
const int DRY_RAW = BASIL_DRY_RAW;
const int WET_RAW = BASIL_WET_RAW;


// =====================================================
// 5. 측정 및 전송 설정
// =====================================================

const int SAMPLE_COUNT = 10;

// 테스트용: 10초마다 전송
//const unsigned long SEND_INTERVAL_MS = 10UL * 1000UL;

// 실제 운영용: 10분마다 전송
const unsigned long SEND_INTERVAL_MS = 10UL * 60UL * 1000UL;

unsigned long lastSendTime = 0;


// =====================================================
// 6. 함수 선언
// =====================================================

void connectWiFi();
void ensureWiFiConnected();

int readSoilRaw();
double convertRawToPercent(int raw);

String createJsonBody(int soilRaw, double soilPercent);
bool sendSoilMoistureData(int soilRaw, double soilPercent);

void measureAndSend();


// =====================================================
// 7. setup
// =====================================================

void setup() {
    Serial.begin(115200);
    delay(1000);

    Serial.println();
    Serial.println("====================================");
    Serial.println("GreenLink ESP32 Soil Moisture 시작");
    Serial.println("====================================");

    Serial.print("DEVICE_KEY: ");
    Serial.println(DEVICE_KEY);

    Serial.print("SOIL_SENSOR_PIN: ");
    Serial.println(SOIL_SENSOR_PIN);

    Serial.print("DRY_RAW: ");
    Serial.println(DRY_RAW);

    Serial.print("WET_RAW: ");
    Serial.println(WET_RAW);

    if (DRY_RAW <= WET_RAW) {
        Serial.println("[ERROR] DRY_RAW는 WET_RAW보다 커야 합니다.");
        Serial.println("[ERROR] 보정값을 다시 확인하세요.");
    }

    analogReadResolution(12);
    analogSetPinAttenuation(SOIL_SENSOR_PIN, ADC_11db);

    connectWiFi();

    measureAndSend();

    lastSendTime = millis();
}


// =====================================================
// 8. loop
// =====================================================

void loop() {
    unsigned long currentTime = millis();

    if (currentTime - lastSendTime >= SEND_INTERVAL_MS) {
        measureAndSend();
        lastSendTime = currentTime;
    }

    delay(1000);
}


// =====================================================
// 9. 토양수분 raw 값 읽기
// =====================================================

int readSoilRaw() {
    long sum = 0;

    Serial.println();
    Serial.println("[RAW 샘플 측정 시작]");

    for (int i = 0; i < SAMPLE_COUNT; i++) {
        int value = analogRead(SOIL_SENSOR_PIN);

        Serial.print("sample ");
        Serial.print(i + 1);
        Serial.print(": ");
        Serial.println(value);

        sum += value;
        delay(50);
    }

    int average = (int)(sum / SAMPLE_COUNT);

    Serial.print("[RAW 평균] ");
    Serial.println(average);

    return average;
}


// =====================================================
// 10. raw 값을 percent로 변환
// =====================================================

double convertRawToPercent(int raw) {
    if (DRY_RAW == WET_RAW) {
        Serial.println("[ERROR] DRY_RAW와 WET_RAW가 같습니다. 보정값을 다시 확인하세요.");
        return 0.0;
    }

    double percent = ((double)(DRY_RAW - raw) / (double)(DRY_RAW - WET_RAW)) * 100.0;

    if (raw > DRY_RAW) {
        Serial.println("[WARN] raw가 DRY_RAW보다 큽니다. 0%로 보정합니다.");
    }

    if (raw < WET_RAW) {
        Serial.println("[WARN] raw가 WET_RAW보다 작습니다. 100%로 보정합니다.");
    }

    if (percent < 0.0) {
        percent = 0.0;
    }

    if (percent > 100.0) {
        percent = 100.0;
    }

    return round(percent * 10.0) / 10.0;
}


// =====================================================
// 11. JSON Body 생성
// =====================================================

String createJsonBody(int soilRaw, double soilPercent) {
    String jsonBody = "{";
    jsonBody += "\"soilMoistureRaw\":";
    jsonBody += soilRaw;
    jsonBody += ",";
    jsonBody += "\"soilMoisturePercent\":";
    jsonBody += String(soilPercent, 1);
    jsonBody += "}";

    return jsonBody;
}


// =====================================================
// 12. Spring Boot 서버로 데이터 전송
// =====================================================

bool sendSoilMoistureData(int soilRaw, double soilPercent) {
    ensureWiFiConnected();

    HTTPClient http;

    http.setTimeout(5000);
    http.begin(SERVER_URL);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("X-DEVICE-KEY", DEVICE_KEY);

    String jsonBody = createJsonBody(soilRaw, soilPercent);

    Serial.println();
    Serial.println("====================================");
    Serial.println("[서버 전송 시작]");
    Serial.print("SERVER_URL: ");
    Serial.println(SERVER_URL);
    Serial.print("DEVICE_KEY: ");
    Serial.println(DEVICE_KEY);
    Serial.println("[전송 JSON]");
    Serial.println(jsonBody);
    Serial.println("====================================");

    int httpResponseCode = http.POST(jsonBody);

    if (httpResponseCode > 0) {
        String responseBody = http.getString();

        Serial.print("HTTP Code: ");
        Serial.println(httpResponseCode);

        Serial.print("Response: ");
        Serial.println(responseBody);

        http.end();

        if (httpResponseCode >= 200 && httpResponseCode < 300) {
            Serial.println("[서버 전송 성공]");
            return true;
        }

        Serial.println("[서버 전송 실패]");
        return false;
    }

    Serial.print("HTTP Error: ");
    Serial.println(http.errorToString(httpResponseCode));

    http.end();

    return false;
}


// =====================================================
// 13. 측정 후 서버 전송
// =====================================================

void measureAndSend() {
    int raw = readSoilRaw();
    double percent = convertRawToPercent(raw);

    Serial.println();
    Serial.println("====================================");
    Serial.println("[측정 결과]");

    Serial.print("DRY_RAW: ");
    Serial.println(DRY_RAW);

    Serial.print("WET_RAW: ");
    Serial.println(WET_RAW);

    Serial.print("soilMoistureRaw: ");
    Serial.println(raw);

    Serial.print("soilMoisturePercent: ");
    Serial.print(percent, 1);
    Serial.println("%");

    if (raw > DRY_RAW) {
        Serial.println("[판단] 기준상 매우 건조 또는 공기 중/접촉 불량 가능성");
    } else if (raw < WET_RAW) {
        Serial.println("[판단] 기준상 매우 젖음 또는 과습 가능성");
    } else {
        Serial.println("[판단] dryRaw와 wetRaw 사이 정상 범위");
    }

    Serial.println("====================================");

    sendSoilMoistureData(raw, percent);
}


// =====================================================
// 14. Wi-Fi 연결
// =====================================================

void connectWiFi() {
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    Serial.println();
    Serial.println("====================================");
    Serial.println("[Wi-Fi 연결 시도]");
    Serial.print("SSID: ");
    Serial.println(WIFI_SSID);
    Serial.println("====================================");

    int retryCount = 0;

    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");

        retryCount++;

        if (retryCount >= 60) {
            Serial.println();
            Serial.println("[Wi-Fi 연결 실패] ESP32를 재시작합니다.");
            ESP.restart();
        }
    }

    Serial.println();
    Serial.print("[Wi-Fi 연결 성공] IP: ");
    Serial.println(WiFi.localIP());
}


// =====================================================
// 15. Wi-Fi 연결 상태 확인
// =====================================================

void ensureWiFiConnected() {
    if (WiFi.status() == WL_CONNECTED) {
        return;
    }

    Serial.println("[Wi-Fi 끊김] 재연결 시도");
    connectWiFi();
}