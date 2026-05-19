package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.iot.GrowSpace;
import com.greenlink.greenlink.domain.iot.IotDevice;
import com.greenlink.greenlink.domain.iot.PumpChannel;
import com.greenlink.greenlink.domain.plant.UserPlant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PumpChannelRepository extends JpaRepository<PumpChannel, Long> {

    List<PumpChannel> findAllByDeletedFalse();

    Optional<PumpChannel> findByIdAndDeletedFalse(Long id);

    Optional<PumpChannel> findByIdAndActiveTrueAndDeletedFalse(Long id);

    List<PumpChannel> findAllByGrowSpaceAndDeletedFalse(GrowSpace growSpace);

    List<PumpChannel> findAllByGrowSpaceAndActiveTrueAndDeletedFalse(GrowSpace growSpace);

    Optional<PumpChannel> findByUserPlantAndDeletedFalse(UserPlant userPlant);

    Optional<PumpChannel> findByUserPlantAndActiveTrueAndDeletedFalse(UserPlant userPlant);

    boolean existsByUserPlantAndDeletedFalse(UserPlant userPlant);

    List<PumpChannel> findAllByRaspberryDeviceAndDeletedFalse(IotDevice raspberryDevice);

    List<PumpChannel> findAllByRaspberryDeviceAndActiveTrueAndDeletedFalse(IotDevice raspberryDevice);

    Optional<PumpChannel> findByGrowSpaceAndUserPlantAndActiveTrueAndDeletedFalse(
            GrowSpace growSpace,
            UserPlant userPlant
    );
}