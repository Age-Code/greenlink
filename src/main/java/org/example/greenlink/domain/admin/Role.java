package org.example.greenlink.domain.admin;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import lombok.Getter;
import lombok.Setter;
import org.example.greenlink.domain.AuditingFields;
import org.example.greenlink.dto.admin.RoleDto;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class Role extends AuditingFields {

    Long createUserId;
    String roleName;
    String content;

    protected Role() {}
    private Role(Long createUserId, String roleName, String content) {
        this.createUserId = createUserId;
        this.roleName = roleName;
        this.content = content;
    }
    public static Role of(Long createUserId, String roleName, String content) {
        return new Role(createUserId, roleName, content);
    }

    public RoleDto.CreateResDto toCreateResDto() {
        return RoleDto.CreateResDto.builder().id(getId()).build();
    }
}
