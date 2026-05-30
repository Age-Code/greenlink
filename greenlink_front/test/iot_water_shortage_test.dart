import 'package:flutter_test/flutter_test.dart';
import 'package:front/models/iot_models.dart';

void main() {
  IotLatestStatus latestWithSoil(double? moisture) {
    return IotLatestStatus.fromJson({
      'userPlantId': 5,
      'soil': {
        'sensorDataId': 1,
        'soilMoistureRaw': 2500,
        'soilMoisturePercent': moisture,
        'measuredAt': '2026-05-20T18:10:00',
      },
    });
  }

  test('soilMoisturePercent 24.5 is water shortage', () {
    final latest = latestWithSoil(24.5);

    expect(latest.isWaterShortage, isTrue);
    expect(latest.soilMoisturePercent, 24.5);
  });

  test('soilMoisturePercent 30.0 is not water shortage', () {
    final latest = latestWithSoil(30.0);

    expect(latest.isWaterShortage, isFalse);
  });

  test('soilMoisturePercent 80.0 is not water shortage', () {
    final latest = latestWithSoil(80.0);

    expect(latest.isWaterShortage, isFalse);
  });

  test('null soil is not water shortage', () {
    final latest = IotLatestStatus.fromJson({
      'userPlantId': 5,
      'soil': null,
    });

    expect(latest.isWaterShortage, isFalse);
    expect(latest.soilMoisturePercent, isNull);
  });

  test('null soilMoisturePercent is not water shortage', () {
    final latest = latestWithSoil(null);

    expect(latest.isWaterShortage, isFalse);
    expect(latest.soilMoisturePercent, isNull);
  });

  test('soilMoisturePercent 82.3 is too wet and cannot water', () {
    final latest = latestWithSoil(82.3);

    expect(latest.isTooWet, isTrue);
    expect(latest.canWater, isFalse);
  });

  test('soilMoisturePercent 80.0 is too wet and cannot water', () {
    final latest = latestWithSoil(80.0);

    expect(latest.isTooWet, isTrue);
    expect(latest.canWater, isFalse);
  });

  test('soilMoisturePercent 79.9 can water', () {
    final latest = latestWithSoil(79.9);

    expect(latest.isTooWet, isFalse);
    expect(latest.canWater, isTrue);
  });
}
