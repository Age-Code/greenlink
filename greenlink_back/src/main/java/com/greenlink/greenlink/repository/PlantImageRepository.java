package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.iot.GrowSpace;
import com.greenlink.greenlink.domain.iot.IotDevice;
import com.greenlink.greenlink.domain.iot.PlantImage;
import com.greenlink.greenlink.domain.plant.UserPlant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PlantImageRepository extends JpaRepository<PlantImage, Long> {

    List<PlantImage> findAllByGrowSpaceAndDeletedFalseOrderByCapturedAtDesc(
            GrowSpace growSpace
    );

    Optional<PlantImage> findFirstByGrowSpaceAndDeletedFalseOrderByCapturedAtDesc(
            GrowSpace growSpace
    );

    List<PlantImage> findAllByUserPlantAndDeletedFalseOrderByCapturedAtDesc(
            UserPlant userPlant
    );

    Optional<PlantImage> findFirstByUserPlantAndDeletedFalseOrderByCapturedAtDesc(
            UserPlant userPlant
    );

    List<PlantImage> findAllByIotDeviceAndDeletedFalseOrderByCapturedAtDesc(
            IotDevice iotDevice
    );

    Optional<PlantImage> findFirstByIotDeviceAndDeletedFalseOrderByCapturedAtDesc(
            IotDevice iotDevice
    );
}