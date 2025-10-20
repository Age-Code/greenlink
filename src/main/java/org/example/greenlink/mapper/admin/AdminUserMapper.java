package org.example.greenlink.mapper.admin;

import org.example.greenlink.dto.admin.AdminUserDto;

import java.util.List;

public interface AdminUserMapper {
    AdminUserDto.DetailResDto detail(AdminUserDto.DetailSevDto detailSevDto);
    List<AdminUserDto.ListResDto> list(AdminUserDto.ListSevDto listSevDto);
}
