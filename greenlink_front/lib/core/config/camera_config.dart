import '../constants/stream_urls.dart';

/// 카메라 관련 상수
/// MJPEG 스트림 URL은 Cloudflare Tunnel을 통해 공개되므로
/// Authorization 헤더 없이 직접 접근 가능.
class CameraConfig {
  CameraConfig._();

  /// 라즈베리파이 실시간 MJPEG 스트림 주소
  static const String streamUrl = StreamUrls.all;

  /// 식물 ID에 따른 실시간 MJPEG 스트림 주소 반환
  static String getCameraStreamUrl(int userPlantId) {
    if (userPlantId == 5) {
      return StreamUrls.sunflower;
    }

    if (userPlantId == 6) {
      return StreamUrls.basil;
    }

    return streamUrl;
  }
}
