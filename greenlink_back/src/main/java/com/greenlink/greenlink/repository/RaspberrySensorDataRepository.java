package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.iot.GrowSpace;
import com.greenlink.greenlink.domain.iot.IotDevice;
import com.greenlink.greenlink.domain.iot.RaspberrySensorData;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface RaspberrySensorDataRepository extends JpaRepository<RaspberrySensorData, Long> {

    List<RaspberrySensorData> findAllByGrowSpaceAndDeletedFalseOrderByMeasuredAtDesc(
            GrowSpace growSpace
    );

    Optional<RaspberrySensorData> findFirstByGrowSpaceAndDeletedFalseOrderByMeasuredAtDesc(
            GrowSpace growSpace
    );

    List<RaspberrySensorData> findAllByIotDeviceAndDeletedFalseOrderByMeasuredAtDesc(
            IotDevice iotDevice
    );

    Optional<RaspberrySensorData> findFirstByIotDeviceAndDeletedFalseOrderByMeasuredAtDesc(
            IotDevice iotDevice
    );

    List<RaspberrySensorData> findByGrowSpaceAndMeasuredAtBetweenOrderByMeasuredAtAsc(
            GrowSpace growSpace,
            LocalDateTime start,
            LocalDateTime end
    );
}