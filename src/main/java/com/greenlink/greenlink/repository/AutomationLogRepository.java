package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.automation.AutomationLog;
import com.greenlink.greenlink.domain.automation.AutomationType;
import com.greenlink.greenlink.domain.plant.UserPlant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface AutomationLogRepository extends JpaRepository<AutomationLog, Long> {

    /**
     * 특정 식물의 자동화 로그 최신순 조회
     */
    List<AutomationLog> findByUserPlantAndDeletedFalseOrderByCreatedAtDesc(
            UserPlant userPlant
    );

    /**
     * 특정 식물의 자동화 로그 중 최근 N개 조회용
     *
     * Service에서 Pageable로 처리해도 되지만,
     * 일단 간단하게 최신 30개 정도만 보고 싶을 때 사용할 수 있다.
     */
    List<AutomationLog> findTop30ByUserPlantAndDeletedFalseOrderByCreatedAtDesc(
            UserPlant userPlant
    );

    /**
     * 특정 식물의 특정 자동화 타입 로그 조회
     */
    List<AutomationLog> findByUserPlantAndAutomationTypeAndDeletedFalseOrderByCreatedAtDesc(
            UserPlant userPlant,
            AutomationType automationType
    );

    /**
     * 특정 시간 이후의 자동화 로그 조회
     *
     * 나중에 학습/분석할 때 최근 7일, 최근 24시간 로그를 볼 수 있게 사용한다.
     */
    List<AutomationLog> findByUserPlantAndCreatedAtAfterAndDeletedFalseOrderByCreatedAtDesc(
            UserPlant userPlant,
            LocalDateTime createdAt
    );
}