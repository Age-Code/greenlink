package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.attend.Attend;
import com.greenlink.greenlink.domain.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AttendRepository extends JpaRepository<Attend, Long> {

    Optional<Attend> findByUserAndAttendDate(User user, LocalDate attendDate);

    boolean existsByUserAndAttendDate(User user, LocalDate attendDate);

    List<Attend> findAllByUserAndAttendDateBetweenOrderByAttendDateAsc(
            User user,
            LocalDate startDate,
            LocalDate endDate
    );

    Optional<Attend> findTopByUserAndAttendDateLessThanEqualOrderByAttendDateDesc(
            User user,
            LocalDate attendDate
    );
}