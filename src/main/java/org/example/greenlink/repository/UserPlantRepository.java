package org.example.greenlink.repository;

import org.example.greenlink.domain.Plant;
import org.example.greenlink.domain.UserPlant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserPlantRepository extends JpaRepository<UserPlant, Long> {
}
