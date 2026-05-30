package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.iot.GrowSpace;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GrowSpaceRepository extends JpaRepository<GrowSpace, Long> {

    List<GrowSpace> findAllByDeletedFalse();

    List<GrowSpace> findAllByActiveTrueAndDeletedFalse();

    Optional<GrowSpace> findByIdAndDeletedFalse(Long id);

    Optional<GrowSpace> findByIdAndActiveTrueAndDeletedFalse(Long id);

    boolean existsByNameAndDeletedFalse(String name);
}