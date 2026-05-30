package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.plant.Plant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PlantRepository extends JpaRepository<Plant, Long> {

    List<Plant> findAllByDeletedFalse();

    Optional<Plant> findByIdAndDeletedFalse(Long id);

    Optional<Plant> findByNameAndDeletedFalse(String name);

    boolean existsByNameAndDeletedFalse(String name);
}