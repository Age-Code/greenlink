package org.example.greenlink.dto.admin;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.example.greenlink.domain.admin.Notice;
import org.example.greenlink.dto.DefaultDto;

import java.time.LocalDateTime;

public class NoticeDto {

    // Create Request Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class CreateReqDto extends DefaultDto.BaseDto {
        String title;
        String content;
    }

    // Create Service Dto
    @Getter @Setter @SuperBuilder @NoArgsConstructor @AllArgsConstructor
    public static class CreateSevDto extends CreateReqDto {
        Long reqUserId;

        public Notice toEntity() { return Notice.of(getReqUserId(), getTitle(), getContent()); }
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
        Long id;
        Boolean deleted;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        LocalDateTime createdAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
        LocalDateTime modifiedAt;
        String title;
        String content;
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
        String title;
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
        String title;
        String content;
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
