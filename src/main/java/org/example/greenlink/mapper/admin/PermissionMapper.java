package org.example.greenlink.mapper.admin;

import org.example.greenlink.dto.admin.PermissionDto;

import java.util.List;

public interface PermissionMapper {
    List<PermissionDto.ListResDto> list(PermissionDto.ListSevDto listSevDto);
}
