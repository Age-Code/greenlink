package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.iot.GrowSpace;
import com.greenlink.greenlink.domain.iot.IotDevice;
import com.greenlink.greenlink.domain.iot.EspSensorData;
import com.greenlink.greenlink.domain.plant.UserPlant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface EspSensorDataRepository extends JpaRepository<EspSensorData, Long> {

    List<EspSensorData> findAllByGrowSpaceAndDeletedFalseOrderByMeasuredAtDesc(
            GrowSpace growSpace
    );

    List<EspSensorData> findAllByUserPlantAndDeletedFalseOrderByMeasuredAtDesc(
            UserPlant userPlant
    );

    Optional<EspSensorData> findFirstByUserPlantAndDeletedFalseOrderByMeasuredAtDesc(
            UserPlant userPlant
    );

    List<EspSensorData> findAllByIotDeviceAndDeletedFalseOrderByMeasuredAtDesc(
            IotDevice iotDevice
    );

    Optional<EspSensorData> findFirstByIotDeviceAndDeletedFalseOrderByMeasuredAtDesc(
            IotDevice iotDevice
    );

    List<EspSensorData> findByUserPlantAndMeasuredAtBetweenOrderByMeasuredAtAsc(
            UserPlant userPlant,
            LocalDateTime start,
            LocalDateTime end
    );

    Optional<EspSensorData> findTopByUserPlantAndMeasuredAtLessThanEqualOrderByMeasuredAtDesc(
            UserPlant userPlant,
            LocalDateTime measuredAt
    );

    Optional<EspSensorData> findTopByUserPlantAndMeasuredAtGreaterThanEqualOrderByMeasuredAtAsc(
            UserPlant userPlant,
            LocalDateTime measuredAt
    );
}