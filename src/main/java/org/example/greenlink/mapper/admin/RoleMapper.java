package org.example.greenlink.mapper.admin;

import org.example.greenlink.dto.admin.RoleDto;

import java.util.List;

public interface RoleMapper {
    RoleDto.DetailResDto detail(RoleDto.DetailSevDto detailSevDto);
    List<RoleDto.ListResDto> list(RoleDto.ListSevDto listSevDto);
}
