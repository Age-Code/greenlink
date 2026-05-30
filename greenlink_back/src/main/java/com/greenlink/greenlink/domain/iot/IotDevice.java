package com.greenlink.greenlink.domain.iot;

import com.greenlink.greenlink.domain.plant.UserPlant;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(
        name = "iot_device",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uq_iot_device_device_key",
                        columnNames = "device_key"
                )
        }
)
public class IotDevice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 라즈베리파이는 growSpace 기준으로 연결된다.
     * ESP도 같은 공간 소속을 표시하기 위해 growSpace를 가질 수 있다.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "grow_space_id")
    private GrowSpace growSpace;

    /**
     * ESP32는 특정 userPlant에 연결된다.
     * RASPBERRY_PI는 userPlant가 null이다.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_plant_id")
    private UserPlant userPlant;

    @Column(nullable = false, length = 100)
    private String deviceName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private DeviceType deviceType;

    @Column(nullable = false, unique = true, length = 100)
    private String deviceKey;

    @Column(nullable = false)
    private Boolean active;

    private LocalDateTime lastConnectedAt;

    @Column(nullable = false)
    private boolean deleted;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime modifiedAt;

    @Builder
    private IotDevice(
            GrowSpace growSpace,
            UserPlant userPlant,
            String deviceName,
            DeviceType deviceType,
            String deviceKey
    ) {
        this.growSpace = growSpace;
        this.userPlant = userPlant;
        this.deviceName = deviceName;
        this.deviceType = deviceType;
        this.deviceKey = deviceKey;
        this.active = true;
        this.deleted = false;
        validateDeviceConnection();
    }

    public static IotDevice createRaspberryPi(
            GrowSpace growSpace,
            String deviceName,
            String deviceKey
    ) {
        return IotDevice.builder()
                .growSpace(growSpace)
                .userPlant(null)
                .deviceName(deviceName)
                .deviceType(DeviceType.RASPBERRY_PI)
                .deviceKey(deviceKey)
                .build();
    }

    public static IotDevice createEsp32(
            GrowSpace growSpace,
            UserPlant userPlant,
            String deviceName,
            String deviceKey
    ) {
        return IotDevice.builder()
                .growSpace(growSpace)
                .userPlant(userPlant)
                .deviceName(deviceName)
                .deviceType(DeviceType.ESP32)
                .deviceKey(deviceKey)
                .build();
    }

    private void validateDeviceConnection() {
        if (this.deviceType == DeviceType.RASPBERRY_PI) {
            if (this.growSpace == null) {
                throw new IllegalStateException("라즈베리파이는 재배 공간에 연결되어야 합니다.");
            }

            if (this.userPlant != null) {
                throw new IllegalStateException("라즈베리파이는 특정 식물에 직접 연결할 수 없습니다.");
            }
        }

        if (this.deviceType == DeviceType.ESP32) {
            if (this.userPlant == null) {
                throw new IllegalStateException("ESP32는 특정 식물에 연결되어야 합니다.");
            }
        }
    }

    public void updateLastConnectedAt() {
        this.lastConnectedAt = LocalDateTime.now();
    }

    public void deactivate() {
        this.active = false;
    }

    public void activate() {
        this.active = true;
    }

    public void delete() {
        this.deleted = true;
        this.active = false;
    }

    public boolean isRaspberryPi() {
        return this.deviceType == DeviceType.RASPBERRY_PI;
    }

    public boolean isEsp32() {
        return this.deviceType == DeviceType.ESP32;
    }

    @PrePersist
    public void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.modifiedAt = now;

        if (this.active == null) {
            this.active = true;
        }
    }

    @PreUpdate
    public void preUpdate() {
        this.modifiedAt = LocalDateTime.now();
    }
}