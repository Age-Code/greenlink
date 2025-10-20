package org.example.greenlink.service.admin;

import org.example.greenlink.dto.admin.PermissionDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface PermissionService {
    PermissionDto.ToggleResDto toggle(PermissionDto.ToggleSevDto toggleSevDto);
    List<PermissionDto.ListResDto> list(PermissionDto.ListSevDto listSevDto);
}
