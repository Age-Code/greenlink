package org.example.greenlink.domain.admin;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import lombok.Getter;
import lombok.Setter;
import org.example.greenlink.domain.AuditingFields;
import org.example.greenlink.dto.admin.NoticeDto;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class Notice extends AuditingFields {

    Long createUserId;
    String title;
    String content;

    protected Notice() {}
    private Notice(Long createUserId, String title, String content) {
        this.createUserId = createUserId;
        this.title = title;
        this.content = content;
    }
    public static Notice of(Long createUserId, String title, String content) {
        return new Notice(createUserId, title, content);
    }

    public NoticeDto.CreateResDto toCreateResDto() {
        return NoticeDto.CreateResDto.builder().id(getId()).build();
    }
}
