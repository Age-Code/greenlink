package org.example.greenlink.domain.admin;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.example.greenlink.domain.AuditingFields;
import org.example.greenlink.dto.admin.RoleUserDto;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(
      indexes = {
              @Index(columnList = "deleted"),
              @Index(columnList = "roleId"),
              @Index(columnList = "userId")
      }
      ,uniqueConstraints = {
              @UniqueConstraint(
                      name = "UQ_roleUser_roleId_userId_",
                      columnNames = {"roleId", "userId"}
              )
      }
)
@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class RoleUser extends AuditingFields {

    Long roleId;
    Long userId;
    Long addUserId;

    protected RoleUser() {}
    private RoleUser(Long roleId, Long userId, Long addUserId) {
        this.roleId = roleId;
        this.userId = userId;
        this.addUserId = addUserId;
    }
    public static RoleUser of(Long roleId, Long userId, Long addUserId) {
        return new RoleUser(roleId, userId, addUserId);
    }

    public RoleUserDto.AddResDto toAddResDto() {return RoleUserDto.AddResDto.builder().id(getId()).build();}
}
