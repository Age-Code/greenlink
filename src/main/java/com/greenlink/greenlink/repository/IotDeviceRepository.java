package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.iot.DeviceType;
import com.greenlink.greenlink.domain.iot.GrowSpace;
import com.greenlink.greenlink.domain.iot.IotDevice;
import com.greenlink.greenlink.domain.plant.UserPlant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface IotDeviceRepository extends JpaRepository<IotDevice, Long> {

    List<IotDevice> findAllByDeletedFalse();

    List<IotDevice> findAllByActiveTrueAndDeletedFalse();

    Optional<IotDevice> findByIdAndDeletedFalse(Long id);

    Optional<IotDevice> findByIdAndActiveTrueAndDeletedFalse(Long id);

    Optional<IotDevice> findByDeviceKeyAndDeletedFalse(String deviceKey);

    Optional<IotDevice> findByDeviceKeyAndActiveTrueAndDeletedFalse(String deviceKey);

    boolean existsByDeviceKeyAndDeletedFalse(String deviceKey);

    List<IotDevice> findAllByGrowSpaceAndDeletedFalse(GrowSpace growSpace);

    List<IotDevice> findAllByGrowSpaceAndActiveTrueAndDeletedFalse(GrowSpace growSpace);

    List<IotDevice> findAllByGrowSpaceAndDeviceTypeAndDeletedFalse(
            GrowSpace growSpace,
            DeviceType deviceType
    );

    List<IotDevice> findAllByGrowSpaceAndDeviceTypeAndActiveTrueAndDeletedFalse(
            GrowSpace growSpace,
            DeviceType deviceType
    );

    Optional<IotDevice> findFirstByGrowSpaceAndDeviceTypeAndActiveTrueAndDeletedFalse(
            GrowSpace growSpace,
            DeviceType deviceType
    );

    Optional<IotDevice> findFirstByUserPlantAndDeviceTypeAndActiveTrueAndDeletedFalse(
            UserPlant userPlant,
            DeviceType deviceType
    );

    List<IotDevice> findAllByUserPlantAndDeletedFalse(UserPlant userPlant);

    List<IotDevice> findAllByUserPlantAndActiveTrueAndDeletedFalse(UserPlant userPlant);

}