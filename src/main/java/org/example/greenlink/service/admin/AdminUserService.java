package org.example.greenlink.service.admin;

import org.example.greenlink.dto.admin.AdminUserDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface AdminUserService {
    AdminUserDto.CreateResDto create(AdminUserDto.CreateSevDto createSevDto);
    AdminUserDto.DetailResDto detail(AdminUserDto.DetailSevDto detailSevDto);
    List<AdminUserDto.ListResDto> list(AdminUserDto.ListSevDto listSevDto);
    void update(AdminUserDto.UpdateSevDto updateSevDto);
    void delete(AdminUserDto.DeleteSevDto deleteSevDto);
}
