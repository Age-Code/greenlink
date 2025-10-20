package org.example.greenlink.service.admin;

import org.example.greenlink.dto.admin.RoleDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface RoleService {
    RoleDto.CreateResDto create(RoleDto.CreateSevDto createSevDto);
    RoleDto.DetailResDto detail(RoleDto.DetailSevDto detailSevDto);
    List<RoleDto.ListResDto> list(RoleDto.ListSevDto listSevDto);
    void update(RoleDto.UpdateSevDto updateSevDto);
    void delete(RoleDto.DeleteSevDto deleteSevDto);
}
