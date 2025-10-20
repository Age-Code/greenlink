package org.example.greenlink.domain.admin;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import lombok.Getter;
import lombok.Setter;
import org.example.greenlink.domain.AuditingFields;
import org.example.greenlink.dto.admin.FaqDto;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class Faq extends AuditingFields {

    Long createUserId;
    String title;
    String content;

    protected Faq() {}
    private Faq(Long createUserId, String title, String content) {
        this.createUserId = createUserId;
        this.title = title;
        this.content = content;
    }
    public static Faq of(Long createUserId, String title, String content) {
        return new Faq(createUserId, title, content);
    }

    public FaqDto.CreateResDto toCreateResDto() {
        return FaqDto.CreateResDto.builder().id(getId()).build();
    }
}
