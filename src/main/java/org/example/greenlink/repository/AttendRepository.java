package org.example.greenlink.repository;

import org.example.greenlink.domain.Attend;
import org.example.greenlink.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AttendRepository extends JpaRepository<Attend,Long> {

    boolean existsByUserAndAttendDate(User u, LocalDate today);

    Optional<Attend> findByUserAndAttendDate(User u, LocalDate yesterday);

    List<Attend> findAllByUserAndAttendDateBetweenOrderByAttendDateAsc(User u, LocalDate startDate, LocalDate endDate);
}
