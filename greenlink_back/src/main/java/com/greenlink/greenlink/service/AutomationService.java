package com.greenlink.greenlink.service;

import com.greenlink.greenlink.domain.automation.AutomationDecisionMode;
import com.greenlink.greenlink.domain.automation.AutomationLog;
import com.greenlink.greenlink.domain.automation.AutomationModel;
import com.greenlink.greenlink.domain.automation.AutomationModelStatus;
import com.greenlink.greenlink.domain.automation.AutomationSetting;
import com.greenlink.greenlink.domain.automation.AutomationType;
import com.greenlink.greenlink.domain.automation.TriggerSensorType;
import com.greenlink.greenlink.domain.iot.CommandStatus;
import com.greenlink.greenlink.domain.iot.CommandType;
import com.greenlink.greenlink.domain.iot.DeviceCommand;
import com.greenlink.greenlink.domain.iot.DeviceType;
import com.greenlink.greenlink.domain.iot.EspSensorData;
import com.greenlink.greenlink.domain.iot.GrowSpace;
import com.greenlink.greenlink.domain.iot.GrowSpacePlant;
import com.greenlink.greenlink.domain.iot.IotDevice;
import com.greenlink.greenlink.domain.iot.PumpChannel;
import com.greenlink.greenlink.domain.iot.RaspberrySensorData;
import com.greenlink.greenlink.domain.plant.UserPlant;
import com.greenlink.greenlink.domain.user.User;
import com.greenlink.greenlink.dto.AutomationDto;
import com.greenlink.greenlink.repository.AutomationLogRepository;
import com.greenlink.greenlink.repository.AutomationModelRepository;
import com.greenlink.greenlink.repository.AutomationSettingRepository;
import com.greenlink.greenlink.repository.DeviceCommandRepository;
import com.greenlink.greenlink.repository.GrowSpacePlantRepository;
import com.greenlink.greenlink.repository.IotDeviceRepository;
import com.greenlink.greenlink.repository.PumpChannelRepository;
import com.greenlink.greenlink.repository.UserPlantRepository;
import com.greenlink.greenlink.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

// 자동화 서비스 — 센서 저장 후 자동 급수/조명 판단 및 명령 생성
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AutomationService {

    private static final double MODEL_CONFIDENCE_THRESHOLD = 0.6;
    private static final double WATERING_SAFETY_MARGIN_PERCENT = 10.0;

    private final AutomationSettingRepository automationSettingRepository;
    private final AutomationLogRepository automationLogRepository;
    private final AutomationModelRepository automationModelRepository;

    private final UserRepository userRepository;
    private final UserPlantRepository userPlantRepository;

    private final DeviceCommandRepository deviceCommandRepository;
    private final PumpChannelRepository pumpChannelRepository;
    private final IotDeviceRepository iotDeviceRepository;
    private final GrowSpacePlantRepository growSpacePlantRepository;

    // 자동화 설정 조회 — 설정이 없으면 기본 설정을 생성해서 반환한다.
    @Transactional
    public AutomationDto.SettingResDto getSetting(
            Long userId,
            Long userPlantId
    ) {
        User user = findActiveUser(userId);
        UserPlant userPlant = findMyUserPlant(userPlantId, user);

        AutomationSetting setting = getOrCreateDefaultSetting(user, userPlant);

        return AutomationDto.SettingResDto.from(setting);
    }

    // 자동화 설정 수정
    @Transactional
    public AutomationDto.SettingResDto updateSetting(
            Long userId,
            Long userPlantId,
            AutomationDto.UpdateSettingReqDto request
    ) {
        User user = findActiveUser(userId);
        UserPlant userPlant = findMyUserPlant(userPlantId, user);

        AutomationSetting setting = getOrCreateDefaultSetting(user, userPlant);

        validateSettingRequest(request);

        setting.updateSetting(
                request.getAutoWaterEnabled(),
                request.getAutoLightEnabled(),
                request.getWaterThresholdPercent(),
                request.getWaterCooldownMinutes(),
                request.getLightOnThresholdLux(),
                request.getLightOffThresholdLux(),
                request.getLightStartTime(),
                request.getLightEndTime(),
                request.getLightCooldownMinutes(),
                request.getAutoOptimizeEnabled(),
                request.getDecisionMode(),
                request.getMinLearningDataCount()
        );

        if (request.getWateringSafetyEnabled() != null) {
            setting.updateWateringSafetyEnabled(request.getWateringSafetyEnabled());
        }

        return AutomationDto.SettingResDto.from(setting);
    }

    // 자동화 로그 조회
    public List<AutomationDto.LogResDto> getLogs(
            Long userId,
            Long userPlantId
    ) {
        User user = findActiveUser(userId);
        UserPlant userPlant = findMyUserPlant(userPlantId, user);

        return automationLogRepository
                .findTop5ByUserPlantAndDeletedFalseOrderByCreatedAtDesc(userPlant)
                .stream()
                .map(AutomationDto.LogResDto::from)
                .toList();
    }

    // ESP 토양수분 데이터 저장 직후 호출된다. — 학습 모델 기준값이 사용 가능하면 학습 기준값을 사용하고,
    @Transactional
    public void evaluateAutoWater(EspSensorData sensorData) {
        if (sensorData == null) {
            System.out.println("[AUTO_WATER] SKIP — sensorData=null");
            return;
        }

        UserPlant userPlant = sensorData.getUserPlant();

        if (userPlant == null) {
            System.out.println("[AUTO_WATER] SKIP — userPlant=null");
            return;
        }

        User user = userPlant.getUser();

        if (user == null) {
            System.out.println("[AUTO_WATER] SKIP — user=null (userPlantId=" + userPlant.getId() + ")");
            return;
        }

        GrowSpace growSpace = sensorData.getGrowSpace();

        if (growSpace == null) {
            System.out.println("[AUTO_WATER] SKIP — growSpace=null (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_WATER,
                    TriggerSensorType.DEVICE_NOT_READY,
                    sensorData.getSoilMoisturePercent(),
                    null,
                    "재배 공간 정보가 없어 자동 급수를 건너뜁니다."
            );
            return;
        }

        AutomationSetting setting = getOrCreateDefaultSetting(user, userPlant);

        Double soilMoisturePercent = sensorData.getSoilMoisturePercent();
        Double waterThreshold = resolveWaterThreshold(userPlant, setting);

        if (soilMoisturePercent == null) {
            System.out.println("[AUTO_WATER] SKIP — soilMoisturePercent=null (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_WATER,
                    TriggerSensorType.SOIL_MOISTURE,
                    null,
                    waterThreshold,
                    "토양수분 퍼센트 값이 없어 자동 급수를 건너뜁니다."
            );
            return;
        }

        if (!Boolean.TRUE.equals(setting.getAutoWaterEnabled())) {
            System.out.println("[AUTO_WATER] SKIP — autoWaterEnabled=false (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_WATER,
                    TriggerSensorType.DISABLED,
                    soilMoisturePercent,
                    waterThreshold,
                    "자동 물 주기가 꺼져 있어 자동 급수를 실행하지 않습니다."
            );
            return;
        }

        System.out.println("[AUTO_WATER] autoWaterEnabled=true, 판단 시작 (userPlantId=" + userPlant.getId() + ")");
        System.out.println("[AUTO_WATER] 수분=" + soilMoisturePercent + "%, 임계치=" + waterThreshold + "%");

        if (soilMoisturePercent > waterThreshold) {
            System.out.println("[AUTO_WATER] SKIP — 수분이 임계치보다 높아 급수 불필요 (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_WATER,
                    TriggerSensorType.SOIL_MOISTURE,
                    soilMoisturePercent,
                    waterThreshold,
                    "토양수분이 기준값보다 높아 자동 급수를 실행하지 않습니다."
            );
            return;
        }

        if (setting.isWateringSafetyEnabled()) {
            double safetyThreshold = resolveWateringSafetyThreshold(setting);

            System.out.println("[AUTO_WATER] 과습 안전 모드 체크: 수분=" + soilMoisturePercent
                    + "%, safetyThreshold=" + safetyThreshold + "% (userPlantId=" + userPlant.getId() + ")");

            if (soilMoisturePercent >= safetyThreshold) {
                System.out.println("[AUTO_WATER] SKIP — 과습 안전 모드로 급수 차단 (userPlantId=" + userPlant.getId() + ")");
                saveSkipLog(
                        userPlant,
                        AutomationType.SKIP_WATER,
                        TriggerSensorType.SOIL_MOISTURE,
                        soilMoisturePercent,
                        safetyThreshold,
                        String.format(
                                "과습 안전 모드: 토양 수분 %.1f%%로 급수 차단",
                                soilMoisturePercent
                        )
                );
                return;
            }
        }

        if (hasRunningCommand(userPlant, CommandType.WATER)) {
            System.out.println("[AUTO_WATER] SKIP — 진행 중 WATER 명령 존재 (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_WATER,
                    TriggerSensorType.COMMAND_DUPLICATED,
                    soilMoisturePercent,
                    waterThreshold,
                    "이미 처리 대기 또는 처리 중인 급수 명령이 있어 자동 급수를 건너뜁니다."
            );
            return;
        }

        System.out.println("[AUTO_WATER] cooldown 체크: 마지막 급수 후 경과 시간 확인 (userPlantId=" + userPlant.getId() + ")");

        if (isRecentlyCommandCreated(
                userPlant,
                CommandType.WATER,
                setting.getWaterCooldownMinutes()
        )) {
            System.out.println("[AUTO_WATER] SKIP — cooldown 미경과 (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_WATER,
                    TriggerSensorType.COOLDOWN,
                    soilMoisturePercent,
                    waterThreshold,
                    "최근 급수 명령이 있어 쿨다운 시간 동안 자동 급수를 건너뜁니다."
            );
            return;
        }

        IotDevice raspberryDevice = iotDeviceRepository
                .findFirstByGrowSpaceAndDeviceTypeAndActiveTrueAndDeletedFalse(
                        growSpace,
                        DeviceType.RASPBERRY_PI
                )
                .orElse(null);

        if (raspberryDevice == null) {
            System.out.println("[AUTO_WATER] SKIP — 활성 Pi 없음 (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_WATER,
                    TriggerSensorType.DEVICE_NOT_READY,
                    soilMoisturePercent,
                    waterThreshold,
                    "재배 공간에 연결된 라즈베리파이가 없어 자동 급수를 건너뜁니다."
            );
            return;
        }

        PumpChannel pumpChannel = pumpChannelRepository
                .findByGrowSpaceAndUserPlantAndActiveTrueAndDeletedFalse(
                        growSpace,
                        userPlant
                )
                .orElse(null);

        if (pumpChannel == null) {
            System.out.println("[AUTO_WATER] SKIP — 펌프 채널 없음 (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_WATER,
                    TriggerSensorType.DEVICE_NOT_READY,
                    soilMoisturePercent,
                    waterThreshold,
                    "식물에 연결된 펌프 채널이 없어 자동 급수를 건너뜁니다."
            );
            return;
        }

        DeviceCommand command = DeviceCommand.createWaterCommand(
                growSpace,
                userPlant,
                raspberryDevice,
                pumpChannel
        );

        DeviceCommand savedCommand = deviceCommandRepository.save(command);

        System.out.println("[AUTO_WATER] WATER 명령 생성 완료 (commandId=" + savedCommand.getId()
                + ", userPlantId=" + userPlant.getId() + ")");

        saveExecutedLog(
                userPlant,
                AutomationType.AUTO_WATER,
                TriggerSensorType.SOIL_MOISTURE,
                soilMoisturePercent,
                waterThreshold,
                savedCommand,
                "토양수분 "
                        + soilMoisturePercent
                        + "%가 기준 "
                        + waterThreshold
                        + "% 이하라 자동 급수 명령을 생성했습니다."
        );
    }

    // Raspberry 환경 데이터 저장 직후 호출된다. — 학습 모델 기준값이 사용 가능하면 학습 조도 기준값을 사용하고,
    @Transactional
    public void evaluateAutoLight(RaspberrySensorData sensorData) {
        if (sensorData == null) {
            System.out.println("[AUTO_LIGHT] SKIP — sensorData=null");
            return;
        }

        GrowSpace growSpace = sensorData.getGrowSpace();

        if (growSpace == null) {
            System.out.println("[AUTO_LIGHT] SKIP — growSpace=null");
            return;
        }

        Double light = sensorData.getLight();

        if (light == null) {
            System.out.println("[AUTO_LIGHT] SKIP — light=null (growSpaceId=" + growSpace.getId() + ")");
            return;
        }

        System.out.println("[AUTO_LIGHT] 판단 시작: 조도=" + light + " lux (growSpaceId=" + growSpace.getId() + ")");

        IotDevice raspberryDevice = iotDeviceRepository
                .findFirstByGrowSpaceAndDeviceTypeAndActiveTrueAndDeletedFalse(
                        growSpace,
                        DeviceType.RASPBERRY_PI
                )
                .orElse(null);

        if (raspberryDevice == null) {
            System.out.println("[AUTO_LIGHT] SKIP — 활성 Pi 없음 (growSpaceId=" + growSpace.getId() + ")");
            return;
        }

        List<GrowSpacePlant> growSpacePlants =
                growSpacePlantRepository.findByGrowSpaceAndActiveTrueAndDeletedFalse(growSpace);

        if (growSpacePlants.isEmpty()) {
            System.out.println("[AUTO_LIGHT] SKIP — growSpace에 활성 식물 없음 (growSpaceId=" + growSpace.getId() + ")");
            return;
        }

        for (GrowSpacePlant growSpacePlant : growSpacePlants) {
            UserPlant userPlant = growSpacePlant.getUserPlant();

            if (userPlant == null || userPlant.getUser() == null) {
                System.out.println("[AUTO_LIGHT] SKIP — userPlant 또는 user 없음 (growSpaceId=" + growSpace.getId() + ")");
                continue;
            }

            evaluateAutoLightForUserPlant(
                    userPlant,
                    growSpace,
                    raspberryDevice,
                    light
            );
        }
    }

    // 특정 식물 기준으로 자동 LED 판단 — LED는 growSpace 단위 장치이지만,
    private void evaluateAutoLightForUserPlant(
            UserPlant userPlant,
            GrowSpace growSpace,
            IotDevice raspberryDevice,
            Double light
    ) {
        AutomationSetting setting =
                getOrCreateDefaultSetting(userPlant.getUser(), userPlant);

        Double lightOnThreshold = resolveLightOnThreshold(userPlant, setting);
        Double lightOffThreshold = resolveLightOffThreshold(userPlant, setting);

        if (!Boolean.TRUE.equals(setting.getAutoLightEnabled())) {
            System.out.println("[AUTO_LIGHT] SKIP — autoLightEnabled=false (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_LIGHT,
                    TriggerSensorType.DISABLED,
                    light,
                    lightOnThreshold,
                    "자동 조명이 꺼져 있어 자동 조명 제어를 실행하지 않습니다."
            );
            return;
        }

        System.out.println("[AUTO_LIGHT] autoLightEnabled=true, 판단 시작 (userPlantId=" + userPlant.getId() + ")");
        System.out.println("[AUTO_LIGHT] 조도=" + light + ", ON임계치=" + lightOnThreshold
                + ", OFF임계치=" + lightOffThreshold + " (userPlantId=" + userPlant.getId() + ")");

        LocalTime now = LocalTime.now();

        boolean inLightTime = isTimeWithinRange(
                now,
                setting.getLightStartTime(),
                setting.getLightEndTime()
        );

        System.out.println("[AUTO_LIGHT] 시간대 체크: 현재=" + now
                + ", 허용=" + setting.getLightStartTime() + "~" + setting.getLightEndTime()
                + " (userPlantId=" + userPlant.getId() + ")");

        if (!inLightTime) {
            System.out.println("[AUTO_LIGHT] 시간대 외 — LIGHT_OFF 판단 진행 (userPlantId=" + userPlant.getId() + ")");
            createLightCommandIfPossible(
                    userPlant,
                    growSpace,
                    raspberryDevice,
                    CommandType.LIGHT_OFF,
                    AutomationType.AUTO_LIGHT_OFF,
                    TriggerSensorType.TIME,
                    light,
                    lightOffThreshold,
                    setting.getLightCooldownMinutes(),
                    "자동 조명 작동 시간이 아니므로 LED OFF 명령을 생성했습니다."
            );
            return;
        }

        if (light <= lightOnThreshold) {
            System.out.println("[AUTO_LIGHT] LIGHT_ON 조건 충족 (userPlantId=" + userPlant.getId() + ")");
            createLightCommandIfPossible(
                    userPlant,
                    growSpace,
                    raspberryDevice,
                    CommandType.LIGHT_ON,
                    AutomationType.AUTO_LIGHT_ON,
                    TriggerSensorType.LIGHT,
                    light,
                    lightOnThreshold,
                    setting.getLightCooldownMinutes(),
                    "조도 "
                            + light
                            + " lux가 ON 기준 "
                            + lightOnThreshold
                            + " lux 이하라 LED ON 명령을 생성했습니다."
            );
            return;
        }

        if (light >= lightOffThreshold) {
            System.out.println("[AUTO_LIGHT] LIGHT_OFF 조건 충족 (userPlantId=" + userPlant.getId() + ")");
            createLightCommandIfPossible(
                    userPlant,
                    growSpace,
                    raspberryDevice,
                    CommandType.LIGHT_OFF,
                    AutomationType.AUTO_LIGHT_OFF,
                    TriggerSensorType.LIGHT,
                    light,
                    lightOffThreshold,
                    setting.getLightCooldownMinutes(),
                    "조도 "
                            + light
                            + " lux가 OFF 기준 "
                            + lightOffThreshold
                            + " lux 이상이라 LED OFF 명령을 생성했습니다."
            );
            return;
        }

        System.out.println("[AUTO_LIGHT] SKIP — 조도값이 제어 구간 밖 (userPlantId=" + userPlant.getId() + ")");

        saveSkipLog(
                userPlant,
                AutomationType.SKIP_LIGHT,
                TriggerSensorType.LIGHT,
                light,
                lightOnThreshold,
                "조도값이 자동 조명 제어 구간에 해당하지 않아 명령을 생성하지 않습니다."
        );
    }

    // LIGHT_ON / LIGHT_OFF 명령 생성 공통 로직
    private void createLightCommandIfPossible(
            UserPlant userPlant,
            GrowSpace growSpace,
            IotDevice raspberryDevice,
            CommandType commandType,
            AutomationType automationType,
            TriggerSensorType triggerSensorType,
            Double triggerValue,
            Double thresholdValue,
            Integer cooldownMinutes,
            String successMessage
    ) {
        if (hasRunningCommand(userPlant, CommandType.LIGHT_ON)
                || hasRunningCommand(userPlant, CommandType.LIGHT_OFF)) {
            System.out.println("[AUTO_LIGHT] SKIP — 진행 중 조명 명령 존재 (userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_LIGHT,
                    TriggerSensorType.COMMAND_DUPLICATED,
                    triggerValue,
                    thresholdValue,
                    "이미 처리 대기 또는 처리 중인 조명 명령이 있어 자동 조명 제어를 건너뜁니다."
            );
            return;
        }

        System.out.println("[AUTO_LIGHT] cooldown 체크: 마지막 조명 명령 후 경과 시간 확인 (commandType="
                + commandType + ", userPlantId=" + userPlant.getId() + ")");

        boolean recentlyLightOn = isRecentlyCommandCreated(
                userPlant,
                CommandType.LIGHT_ON,
                cooldownMinutes
        );

        boolean recentlyLightOff = isRecentlyCommandCreated(
                userPlant,
                CommandType.LIGHT_OFF,
                cooldownMinutes
        );

        if (recentlyLightOn || recentlyLightOff) {
            System.out.println("[AUTO_LIGHT] SKIP — cooldown 미경과 (commandType="
                    + commandType + ", userPlantId=" + userPlant.getId() + ")");
            saveSkipLog(
                    userPlant,
                    AutomationType.SKIP_LIGHT,
                    TriggerSensorType.COOLDOWN,
                    triggerValue,
                    thresholdValue,
                    "최근 조명 명령이 있어 쿨다운 시간 동안 자동 조명 제어를 건너뜁니다."
            );
            return;
        }

        DeviceCommand command = DeviceCommand.createLightCommand(
                growSpace,
                userPlant,
                raspberryDevice,
                commandType
        );

        DeviceCommand savedCommand = deviceCommandRepository.save(command);

        System.out.println("[AUTO_LIGHT] " + commandType + " 명령 생성 완료 (commandId="
                + savedCommand.getId() + ", userPlantId=" + userPlant.getId() + ")");

        saveExecutedLog(
                userPlant,
                automationType,
                triggerSensorType,
                triggerValue,
                thresholdValue,
                savedCommand,
                successMessage
        );
    }

    // 자동 급수 기준값 결정 — 학습 모델 우선, 없으면 설정값 사용
    private Double resolveWaterThreshold(
            UserPlant userPlant,
            AutomationSetting setting
    ) {
        Double fallbackThreshold = setting.getWaterThresholdPercent();

        if (fallbackThreshold == null) {
            fallbackThreshold = 35.0;
        }

        if (setting.getDecisionMode() == AutomationDecisionMode.RULE_BASED) {
            return fallbackThreshold;
        }

        AutomationModel model = findUsableLearningModel(userPlant, setting);

        if (model == null) {
            return fallbackThreshold;
        }

        if (model.getRecommendedWaterThresholdPercent() == null) {
            return fallbackThreshold;
        }

        return model.getRecommendedWaterThresholdPercent();
    }

    // resolve Watering Safety Threshold 처리
    private double resolveWateringSafetyThreshold(AutomationSetting setting) {
        Double waterThresholdPercent = setting.getWaterThresholdPercent();

        if (waterThresholdPercent == null) {
            waterThresholdPercent = 35.0;
        }

        return waterThresholdPercent + WATERING_SAFETY_MARGIN_PERCENT;
    }

    // 자동 LED ON 기준값 결정
    private Double resolveLightOnThreshold(
            UserPlant userPlant,
            AutomationSetting setting
    ) {
        Double fallbackThreshold = setting.getLightOnThresholdLux();

        if (fallbackThreshold == null) {
            fallbackThreshold = 300.0;
        }

        if (setting.getDecisionMode() == AutomationDecisionMode.RULE_BASED) {
            return fallbackThreshold;
        }

        AutomationModel model = findUsableLearningModel(userPlant, setting);

        if (model == null) {
            return fallbackThreshold;
        }

        if (model.getRecommendedLightOnThresholdLux() == null) {
            return fallbackThreshold;
        }

        return model.getRecommendedLightOnThresholdLux();
    }

    // 자동 LED OFF 기준값 결정
    private Double resolveLightOffThreshold(
            UserPlant userPlant,
            AutomationSetting setting
    ) {
        Double fallbackThreshold = setting.getLightOffThresholdLux();

        if (fallbackThreshold == null) {
            fallbackThreshold = 500.0;
        }

        if (setting.getDecisionMode() == AutomationDecisionMode.RULE_BASED) {
            return fallbackThreshold;
        }

        AutomationModel model = findUsableLearningModel(userPlant, setting);

        if (model == null) {
            return fallbackThreshold;
        }

        if (model.getRecommendedLightOffThresholdLux() == null) {
            return fallbackThreshold;
        }

        return model.getRecommendedLightOffThresholdLux();
    }

    // 자동화 판단용 최신 학습 모델 조회 — READY/신뢰도/데이터 수 조건 적용
    private AutomationModel findUsableLearningModel(
            UserPlant userPlant,
            AutomationSetting setting
    ) {
        if (setting.getDecisionMode() == null) {
            return null;
        }

        if (setting.getDecisionMode() == AutomationDecisionMode.RULE_BASED) {
            return null;
        }

        AutomationModel model =
                automationModelRepository
                        .findTopByUserPlantAndModelStatusAndDeletedFalseOrderByLastTrainedAtDesc(
                                userPlant,
                                AutomationModelStatus.READY
                        )
                        .orElse(null);

        if (model == null) {
            return null;
        }

        if (model.getConfidenceScore() == null
                || model.getConfidenceScore() < MODEL_CONFIDENCE_THRESHOLD) {
            return null;
        }

        int minLearningDataCount =
                setting.getMinLearningDataCount() == null
                        ? 30
                        : setting.getMinLearningDataCount();

        if (model.getSoilDataCount() == null
                || model.getSoilDataCount() < minLearningDataCount) {
            return null;
        }

        return model;
    }

    // 자동화 설정이 없으면 기본값으로 생성
    private AutomationSetting getOrCreateDefaultSetting(
            User user,
            UserPlant userPlant
    ) {
        return automationSettingRepository
                .findByUserPlantAndDeletedFalse(userPlant)
                .orElseGet(() -> automationSettingRepository.save(
                        AutomationSetting.createDefault(user, userPlant)
                ));
    }

    // 이미 PENDING 또는 PROCESSING 명령이 있는지 확인
    private boolean hasRunningCommand(
            UserPlant userPlant,
            CommandType commandType
    ) {
        return deviceCommandRepository
                .existsByUserPlantAndCommandTypeAndCommandStatusInAndDeletedFalse(
                        userPlant,
                        commandType,
                        List.of(CommandStatus.PENDING, CommandStatus.PROCESSING)
                );
    }

    // 최근 N분 안에 해당 명령이 생성되었는지 확인
    private boolean isRecentlyCommandCreated(
            UserPlant userPlant,
            CommandType commandType,
            Integer cooldownMinutes
    ) {
        if (cooldownMinutes == null || cooldownMinutes <= 0) {
            return false;
        }

        return deviceCommandRepository
                .findTopByUserPlantAndCommandTypeAndDeletedFalseOrderByRequestedAtDesc(
                        userPlant,
                        commandType
                )
                .map(command -> {
                    LocalDateTime requestedAt = command.getRequestedAt();

                    if (requestedAt == null) {
                        return false;
                    }

                    LocalDateTime cooldownBoundary =
                            LocalDateTime.now().minusMinutes(cooldownMinutes);

                    return requestedAt.isAfter(cooldownBoundary);
                })
                .orElse(false);
    }

    // 조명 작동 시간대 확인 — 자정 넘김 범위 포함
    private boolean isTimeWithinRange(
            LocalTime now,
            LocalTime start,
            LocalTime end
    ) {
        if (start == null || end == null) {
            return true;
        }

        if (start.equals(end)) {
            return true;
        }

        if (start.isBefore(end)) {
            return !now.isBefore(start) && !now.isAfter(end);
        }

        return !now.isBefore(start) || !now.isAfter(end);
    }

    // save Executed Log 저장
    private void saveExecutedLog(
            UserPlant userPlant,
            AutomationType automationType,
            TriggerSensorType triggerSensorType,
            Double triggerValue,
            Double thresholdValue,
            DeviceCommand command,
            String message
    ) {
        automationLogRepository.save(
                AutomationLog.createExecutedLog(
                        userPlant,
                        automationType,
                        triggerSensorType,
                        triggerValue,
                        thresholdValue,
                        command,
                        message
                )
        );
    }

    // save Skip Log 저장
    private void saveSkipLog(
            UserPlant userPlant,
            AutomationType automationType,
            TriggerSensorType triggerSensorType,
            Double triggerValue,
            Double thresholdValue,
            String message
    ) {
        automationLogRepository.save(
                AutomationLog.createSkippedLog(
                        userPlant,
                        automationType,
                        triggerSensorType,
                        triggerValue,
                        thresholdValue,
                        message
                )
        );
    }

    // find Active User 조회 — 없으면 예외 또는 Optional 반환
    private User findActiveUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }

    // find My User Plant 조회 — 없으면 예외 또는 Optional 반환
    private UserPlant findMyUserPlant(
            Long userPlantId,
            User user
    ) {
        return userPlantRepository.findById(userPlantId)
                .filter(userPlant -> userPlant.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new IllegalArgumentException("해당 식물을 찾을 수 없습니다."));
    }

    // validate Setting Request 검증
    private void validateSettingRequest(
            AutomationDto.UpdateSettingReqDto request
    ) {
        if (request == null) {
            throw new IllegalArgumentException("자동화 설정 요청이 비어 있습니다.");
        }

        if (request.getWaterThresholdPercent() != null) {
            if (request.getWaterThresholdPercent() < 0
                    || request.getWaterThresholdPercent() > 100) {
                throw new IllegalArgumentException("물 주기 기준값은 0~100 사이여야 합니다.");
            }
        }

        if (request.getWaterCooldownMinutes() != null) {
            if (request.getWaterCooldownMinutes() < 0) {
                throw new IllegalArgumentException("물 주기 쿨다운은 0 이상이어야 합니다.");
            }
        }

        if (request.getLightOnThresholdLux() != null) {
            if (request.getLightOnThresholdLux() < 0) {
                throw new IllegalArgumentException("LED ON 조도 기준은 0 이상이어야 합니다.");
            }
        }

        if (request.getLightOffThresholdLux() != null) {
            if (request.getLightOffThresholdLux() < 0) {
                throw new IllegalArgumentException("LED OFF 조도 기준은 0 이상이어야 합니다.");
            }
        }

        if (request.getLightOnThresholdLux() != null
                && request.getLightOffThresholdLux() != null) {
            if (request.getLightOnThresholdLux()
                    >= request.getLightOffThresholdLux()) {
                throw new IllegalArgumentException("LED OFF 기준 조도는 LED ON 기준 조도보다 커야 합니다.");
            }
        }

        if (request.getLightCooldownMinutes() != null) {
            if (request.getLightCooldownMinutes() < 0) {
                throw new IllegalArgumentException("조명 쿨다운은 0 이상이어야 합니다.");
            }
        }

        if (request.getMinLearningDataCount() != null) {
            if (request.getMinLearningDataCount() < 1) {
                throw new IllegalArgumentException("최소 학습 데이터 개수는 1 이상이어야 합니다.");
            }
        }
    }
}
