package org.example.greenlink.dto.admin;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.example.greenlink.domain.admin.RoleUser;
import org.example.greenlink.dto.DefaultDto;

import java.time.LocalDateTime;
import java.util.List;

public class RoleUserDto {

    // Permit Service Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class PermitSevDto{
        Long reqUserId;
        String permission;
        Integer func;
    }

    // Add Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class AddSevDto{
        Long roleId;
        Long userId;

        Long reqUserId;

        public RoleUser toEntity() { return RoleUser.of(getRoleId(), getUserId(), getReqUserId()); }
    }

    // Add Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class AddResDto {
        Long id;
    }

    // AddUser Request Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class AddUserReqDto extends DefaultDto.BaseDto {
        List<AddSevDto> addSevDtoList;
    }

    // AddUser Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class AddUserSevDto extends AddUserReqDto {
        Long reqUserId;
    }

    // List Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class ListSevDto {
        Long reqId;
        Boolean deleted;

        Long reqUserId;
    }

    // List Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListResDto {
        Long resId;
        String resName;
        Boolean resDeleted;
        Long addUserId;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        LocalDateTime addedAt;
    }

    // AddList Request Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class AddListReqDto extends DefaultDto.BaseDto {
        Long reqId;
        Boolean deleted;
    }

    // AddList Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class AddListSevDto extends AddListReqDto {
        Long reqUserId;
    }

    // AddList Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class AddListResDto {
        Long resId;
        String resName;
        Boolean resDeleted;
    }

    // Delete Request Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class DeleteReqDto extends DefaultDto.BaseDto {
        Long roleId;
        Long userId;
    }

    // Delete Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class DeleteSevDto extends DeleteReqDto {
        Long reqUserId;
    }


}
