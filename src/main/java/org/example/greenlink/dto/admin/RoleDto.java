package org.example.greenlink.dto.admin;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.example.greenlink.domain.admin.Role;
import org.example.greenlink.dto.DefaultDto;

import java.time.LocalDateTime;
import java.util.List;

public class RoleDto {

    public static String[][] permissions = {
            {"role", "ROLE"},
            {"user", "USER"},
            {"notice", "NOTICE"},
            {"faq", "FAQ"},
    };

    // Create Request Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class CreateReqDto extends DefaultDto.BaseDto {
        String roleName;
        String content;
    }

    // Create Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class CreateSevDto extends CreateReqDto {
        Long reqUserId;

        public Role toEntity() { return Role.of(getReqUserId(), getRoleName(), getContent()); }
    }

    // Create Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class CreateResDto {
        Long id;
    }

    // Detail Request Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class DetailReqDto extends DefaultDto.BaseDto {
        Long id;
    }

    // Detail Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class DetailSevDto extends DetailReqDto {
        Long reqUserId;
    }

    // Detail Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class DetailResDto {
        Long roleId;
        Boolean deleted;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        LocalDateTime createdAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        LocalDateTime modifiedAt;
        String roleName;
        String content;

        String[][] permissions;
        List<PermissionDto.ListResDto> permissionList;
        List<RoleUserDto.ListResDto> roleUserList;
    }

    // List Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class ListSevDto {
        Long reqUserId;
    }

    // List Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListResDto {
        Long id;
        String roleName;
        Long createUserId;
        Boolean deleted;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        LocalDateTime createdAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        LocalDateTime modifiedAt;
    }

    // Update Request Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class UpdateReqDto extends DefaultDto.BaseDto {
        Long id;
        String roleName;
        String content;

        List<PermissionDto.ToggleSevDto> permissionUpdate;
    }

    // Update Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class UpdateSevDto extends UpdateReqDto {
        Long reqUserId;
    }

    // Delete Request Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class DeleteReqDto extends DefaultDto.BaseDto {
        Long id;
    }

    // Delete Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class DeleteSevDto extends DeleteReqDto {
        Long reqUserId;
    }

}
