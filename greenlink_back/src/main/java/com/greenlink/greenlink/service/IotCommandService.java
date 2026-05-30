package com.greenlink.greenlink.service;

import com.greenlink.greenlink.domain.iot.CommandStatus;
import com.greenlink.greenlink.domain.iot.DeviceCommand;
import com.greenlink.greenlink.domain.iot.IotDevice;
import com.greenlink.greenlink.dto.iot.IotDeviceDto;
import com.greenlink.greenlink.repository.DeviceCommandRepository;
import com.greenlink.greenlink.repository.IotDeviceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class IotCommandService {

    private final IotDeviceRepository iotDeviceRepository;
    private final DeviceCommandRepository deviceCommandRepository;

    /**
     * 라즈베리파이 대기 명령 조회
     *
     * Header:
     * X-DEVICE-KEY: RPI-CAPSTONE-001
     *
     * 조회 대상:
     * - 해당 라즈베리파이 기기
     * - commandStatus = PENDING
     * - deleted = false
     */
    public List<IotDeviceDto.PendingCommandResDto> getPendingCommands(
            String deviceKey
    ) {
        IotDevice raspberryDevice = findActiveDeviceByKey(deviceKey);

        validateRaspberryDevice(raspberryDevice);

        return deviceCommandRepository
                .findAllByIotDeviceAndCommandStatusAndDeletedFalseOrderByRequestedAtAsc(
                        raspberryDevice,
                        CommandStatus.PENDING
                )
                .stream()
                .map(IotDeviceDto.PendingCommandResDto::from)
                .toList();
    }

    /**
     * 명령 처리 시작
     *
     * PENDING → PROCESSING
     */
    @Transactional
    public IotDeviceDto.CommandProcessingResDto markCommandProcessing(
            String deviceKey,
            Long commandId
    ) {
        IotDevice raspberryDevice = findActiveDeviceByKey(deviceKey);

        validateRaspberryDevice(raspberryDevice);

        DeviceCommand command = findCommandForDevice(commandId, raspberryDevice);

        command.markProcessing();

        return IotDeviceDto.CommandProcessingResDto.from(command);
    }

    /**
     * 명령 처리 완료
     *
     * success == true  → SUCCESS
     * success == false → FAILED
     */
    @Transactional
    public IotDeviceDto.CommandCompleteResDto completeCommand(
            String deviceKey,
            Long commandId,
            IotDeviceDto.CommandCompleteReqDto request
    ) {
        IotDevice raspberryDevice = findActiveDeviceByKey(deviceKey);

        validateRaspberryDevice(raspberryDevice);

        DeviceCommand command = findCommandForDevice(commandId, raspberryDevice);

        String resultMessage = request.getResultMessage();

        if (request.getSuccess()) {
            command.completeSuccess(
                    resultMessage == null || resultMessage.isBlank()
                            ? "명령 처리 성공"
                            : resultMessage
            );
        } else {
            command.completeFailed(
                    resultMessage == null || resultMessage.isBlank()
                            ? "명령 처리 실패"
                            : resultMessage
            );
        }

        return IotDeviceDto.CommandCompleteResDto.from(command);
    }

    private DeviceCommand findCommandForDevice(
            Long commandId,
            IotDevice raspberryDevice
    ) {
        DeviceCommand command = deviceCommandRepository.findByIdAndDeletedFalse(commandId)
                .orElseThrow(() -> new IllegalArgumentException("명령을 찾을 수 없습니다."));

        if (!command.getIotDevice().getId().equals(raspberryDevice.getId())) {
            throw new IllegalStateException("해당 기기가 처리할 수 있는 명령이 아닙니다.");
        }

        return command;
    }

    private IotDevice findActiveDeviceByKey(String deviceKey) {
        if (deviceKey == null || deviceKey.isBlank()) {
            throw new IllegalArgumentException("X-DEVICE-KEY가 필요합니다.");
        }

        return iotDeviceRepository.findByDeviceKeyAndActiveTrueAndDeletedFalse(deviceKey)
                .orElseThrow(() -> new IllegalArgumentException("등록되지 않았거나 비활성화된 기기입니다."));
    }

    private void validateRaspberryDevice(IotDevice device) {
        if (!device.isRaspberryPi()) {
            throw new IllegalStateException("라즈베리파이 기기만 명령을 처리할 수 있습니다.");
        }
    }
}