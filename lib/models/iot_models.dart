// IoT 상태 모델
// GET /api/user-plants/{userPlantId}/iot/latest 응답

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

  factory IotLatestStatus.fromJson(Map<String, dynamic> json) => IotLatestStatus(
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
}

class GrowSpaceInfo {
  final int growSpaceId;
  final String name;

  GrowSpaceInfo({required this.growSpaceId, required this.name});

  factory GrowSpaceInfo.fromJson(Map<String, dynamic> json) => GrowSpaceInfo(
        growSpaceId: json['growSpaceId'] ?? 0,
        name: json['name'] ?? '',
      );
}

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

  factory EnvironmentData.fromJson(Map<String, dynamic> json) => EnvironmentData(
        sensorDataId: json['sensorDataId'],
        temperature: (json['temperature'] ?? 0).toDouble(),
        humidity: (json['humidity'] ?? 0).toDouble(),
        light: (json['light'] ?? 0).toDouble(),
        measuredAt: json['measuredAt'],
      );
}

class SoilData {
  final int? sensorDataId;
  final int? soilMoistureRaw;
  final double soilMoisturePercent;
  final String? measuredAt;

  SoilData({
    this.sensorDataId,
    this.soilMoistureRaw,
    required this.soilMoisturePercent,
    this.measuredAt,
  });

  factory SoilData.fromJson(Map<String, dynamic> json) => SoilData(
        sensorDataId: json['sensorDataId'],
        soilMoistureRaw: json['soilMoistureRaw'],
        soilMoisturePercent: (json['soilMoisturePercent'] ?? 0).toDouble(),
        measuredAt: json['measuredAt'],
      );
}

class PlantImageData {
  final int? plantImageId;
  final String imageUrl;
  final String? capturedAt;

  PlantImageData({
    this.plantImageId,
    required this.imageUrl,
    this.capturedAt,
  });

  factory PlantImageData.fromJson(Map<String, dynamic> json) => PlantImageData(
        plantImageId: json['plantImageId'],
        imageUrl: json['imageUrl'] ?? '',
        capturedAt: json['capturedAt'],
      );
}

/// POST /api/user-plants/{id}/iot/water 응답
class IotCommandResponse {
  final int? commandId;
  final String commandType;
  final String commandStatus;

  IotCommandResponse({
    this.commandId,
    required this.commandType,
    required this.commandStatus,
  });

  factory IotCommandResponse.fromJson(Map<String, dynamic> json) =>
      IotCommandResponse(
        commandId: json['commandId'],
        commandType: json['commandType'] ?? '',
        commandStatus: json['commandStatus'] ?? '',
      );
}
