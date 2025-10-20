package org.example.greenlink.dto.admin;

import lombok.*;
import lombok.experimental.SuperBuilder;
import org.example.greenlink.domain.admin.Permission;

public class PermissionDto {

    // Toggle Service Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ToggleSevDto{
        Boolean active;
        Long roleId;
        String permission;
        Integer func;

        Long reqUserId;

        public Permission toEntity() { return Permission.of(getRoleId(), getPermission(), getFunc()); }
    }

    // Toggle Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ToggleResDto {
        Long id;
    }

    // List Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class ListSevDto {
        Long roleId;
        Boolean deleted;

        Long reqUserId;
    }

    // List Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListResDto {
        String permission;
        Integer func;
    }

}
