package org.example.greenlink.domain.admin;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.example.greenlink.domain.AuditingFields;
import org.example.greenlink.dto.admin.PermissionDto;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(
      indexes = {
              @Index(columnList = "deleted"),
              @Index(columnList = "roleId"),
              @Index(columnList = "permission"),
              @Index(columnList = "func")
      }
      ,uniqueConstraints = {
              @UniqueConstraint(
                      name = "UQ_permission_roleId_permission_func",
                      columnNames = {"roleId", "permission", "func"}
              )
      }
)
@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class Permission extends AuditingFields {

    Long roleId;
    String permission;
    Integer func;

    protected Permission() {}
    private Permission(Long roleId, String permission, Integer func) {
        this.roleId = roleId;
        this.permission = permission;
        this.func = func;
    }
    public static Permission of(Long roleId, String permission, Integer func) {
        return new Permission(roleId, permission, func);
    }

    public PermissionDto.ToggleResDto toToggleResDto() {return PermissionDto.ToggleResDto.builder().id(getId()).build();}
}
