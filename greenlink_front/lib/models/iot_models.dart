// IoT API 모델

import '../core/constants/iot_thresholds.dart';

// IoT 상태 모델
// GET /api/user-plants/{userPlantId}/iot/latest 응답

// IotLatestStatus — IoT API 모델
class IotLatestStatus {
  final int userPlantId;
  final GrowSpaceInfo? growSpace;
  final EnvironmentData? environment;
  final SoilData? soil;
  final PlantImageData? latestImage;

  IotLatestStatus({
    required this.userPlantId,
    this.growSpace,
    this.environment,
    this.soil,
    this.latestImage,
  });

  // JSON 응답을 모델로 변환
  factory IotLatestStatus.fromJson(Map<String, dynamic> json) =>
      IotLatestStatus(
        userPlantId: json['userPlantId'] ?? 0,
        growSpace: json['growSpace'] != null
            ? GrowSpaceInfo.fromJson(json['growSpace'])
            : null,
        environment: json['environment'] != null
            ? EnvironmentData.fromJson(json['environment'])
            : null,
        soil: json['soil'] != null ? SoilData.fromJson(json['soil']) : null,
        latestImage: json['latestImage'] != null
            ? PlantImageData.fromJson(json['latestImage'])
            : null,
      );

  bool get isWaterShortage {
    final value = soil?.soilMoisturePercent;
    return value != null && value < IotThresholds.soilMoistureShortage;
  }

  bool get isTooWet {
    final value = soil?.soilMoisturePercent;
    return value != null && value >= IotThresholds.soilMoistureTooWet;
  }

  bool get canWater => !isTooWet;

  double? get soilMoisturePercent => soil?.soilMoisturePercent;
}

// GrowSpaceInfo — IoT API 모델
class GrowSpaceInfo {
  final int growSpaceId;
  final String name;

  GrowSpaceInfo({required this.growSpaceId, required this.name});

  // JSON 응답을 모델로 변환
  factory GrowSpaceInfo.fromJson(Map<String, dynamic> json) => GrowSpaceInfo(
    growSpaceId: json['growSpaceId'] ?? 0,
    name: json['name'] ?? '',
  );
}

// EnvironmentData — IoT API 모델
class EnvironmentData {
  final int? sensorDataId;
  final double temperature;
  final double humidity;
  final double light;
  final String? measuredAt;

  EnvironmentData({
    this.sensorDataId,
    required this.temperature,
    required this.humidity,
    required this.light,
    this.measuredAt,
  });

  // JSON 응답을 모델로 변환
  factory EnvironmentData.fromJson(Map<String, dynamic> json) =>
      EnvironmentData(
        sensorDataId: json['sensorDataId'],
        temperature: (json['temperature'] ?? 0).toDouble(),
        humidity: (json['humidity'] ?? 0).toDouble(),
        light: (json['light'] ?? 0).toDouble(),
        measuredAt: json['measuredAt'],
      );
}

// SoilData — IoT API 모델
class SoilData {
  final int? sensorDataId;
  final int? soilMoistureRaw;
  final double? soilMoisturePercent;
  final String? measuredAt;

  SoilData({
    this.sensorDataId,
    this.soilMoistureRaw,
    this.soilMoisturePercent,
    this.measuredAt,
  });

  // JSON 응답을 모델로 변환
  factory SoilData.fromJson(Map<String, dynamic> json) => SoilData(
    sensorDataId: json['sensorDataId'],
    soilMoistureRaw: json['soilMoistureRaw'],
    soilMoisturePercent: _toNullableDouble(json['soilMoisturePercent']),
    measuredAt: json['measuredAt'],
  );
}

// nullable double 변환 — 파싱 실패 시 null 반환
double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

// PlantImageData — IoT API 모델
class PlantImageData {
  final int? plantImageId;
  final String imageUrl;
  final String? aiImageUrl; // AI 변환 이미지 (없을 수 있음)
  final String? capturedAt;

  PlantImageData({
    this.plantImageId,
    required this.imageUrl,
    this.aiImageUrl,
    this.capturedAt,
  });

  // JSON 응답을 모델로 변환
  factory PlantImageData.fromJson(Map<String, dynamic> json) => PlantImageData(
    plantImageId: json['plantImageId'],
    imageUrl: json['imageUrl'] ?? '',
    aiImageUrl: json['aiImageUrl'],
    capturedAt: json['capturedAt'],
  );
}

// IotCommandResponse — API 응답 모델
class IotCommandResponse {
  final int? commandId;
  final String commandType;
  final String commandStatus;

  IotCommandResponse({
    this.commandId,
    required this.commandType,
    required this.commandStatus,
  });

  // JSON 응답을 모델로 변환
  factory IotCommandResponse.fromJson(Map<String, dynamic> json) =>
      IotCommandResponse(
        commandId: json['commandId'],
        commandType: json['commandType'] ?? '',
        commandStatus: json['commandStatus'] ?? '',
      );
}

// SensorRefreshResponse — API 응답 모델
class SensorRefreshResponse {
  final int? userPlantId;
  final int? commandId;
  final String? commandType;
  final String? commandStatus;
  final String? target;
  final bool? alreadyPending;
  final String? duplicateReason;
  final List<String> refreshTargets;
  final List<String> excludedTargets;

  SensorRefreshResponse({
    this.userPlantId,
    this.commandId,
    this.commandType,
    this.commandStatus,
    this.target,
    this.alreadyPending,
    this.duplicateReason,
    this.refreshTargets = const [],
    this.excludedTargets = const [],
  });

  // JSON 응답을 모델로 변환
  factory SensorRefreshResponse.fromJson(Map<String, dynamic> json) {
    return SensorRefreshResponse(
      userPlantId: _toNullableInt(json['userPlantId']),
      commandId: _toNullableInt(json['commandId']),
      commandType: json['commandType']?.toString(),
      commandStatus: json['commandStatus']?.toString(),
      target: json['target']?.toString(),
      alreadyPending: json['alreadyPending'] is bool
          ? json['alreadyPending'] as bool
          : null,
      duplicateReason: json['duplicateReason']?.toString(),
      refreshTargets: _toStringList(json['refreshTargets']),
      excludedTargets: _toStringList(json['excludedTargets']),
    );
  }
}

// nullable int 변환 — 파싱 실패 시 null 반환
int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

// 문자열 리스트 변환 — List가 아니면 빈 목록 반환
List<String> _toStringList(dynamic value) {
  if (value is! List) return [];
  return value.map((e) => e.toString()).toList();
}
