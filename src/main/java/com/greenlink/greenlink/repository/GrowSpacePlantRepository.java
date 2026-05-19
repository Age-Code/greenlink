package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.iot.GrowSpace;
import com.greenlink.greenlink.domain.iot.GrowSpacePlant;
import com.greenlink.greenlink.domain.plant.UserPlant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GrowSpacePlantRepository extends JpaRepository<GrowSpacePlant, Long> {

    List<GrowSpacePlant> findAllByGrowSpaceAndDeletedFalse(GrowSpace growSpace);

    List<GrowSpacePlant> findAllByGrowSpaceAndActiveTrueAndDeletedFalse(GrowSpace growSpace);

    Optional<GrowSpacePlant> findByUserPlantAndDeletedFalse(UserPlant userPlant);

    Optional<GrowSpacePlant> findByUserPlantAndActiveTrueAndDeletedFalse(UserPlant userPlant);

    Optional<GrowSpacePlant> findByGrowSpaceAndUserPlantAndDeletedFalse(
            GrowSpace growSpace,
            UserPlant userPlant
    );

    boolean existsByUserPlantAndDeletedFalse(UserPlant userPlant);

    boolean existsByGrowSpaceAndUserPlantAndDeletedFalse(
            GrowSpace growSpace,
            UserPlant userPlant
    );

    /**
     * 특정 재배 공간에 연결된 활성 식물 목록 조회
     *
     * 자동 LED 판단에서 growSpace 안의 식물 자동화 설정을 확인할 때 사용한다.
     */
    List<GrowSpacePlant> findByGrowSpaceAndActiveTrueAndDeletedFalse(
            GrowSpace growSpace
    );


    Optional<GrowSpacePlant> findTopByUserPlantAndActiveTrueAndDeletedFalse(
            UserPlant userPlant
    );
}