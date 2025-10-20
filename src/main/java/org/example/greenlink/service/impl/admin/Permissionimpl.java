package org.example.greenlink.service.impl.admin;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.admin.Permission;
import org.example.greenlink.dto.admin.PermissionDto;
import org.example.greenlink.mapper.admin.PermissionMapper;
import org.example.greenlink.repository.admin.PermissionRepository;
import org.example.greenlink.service.admin.PermissionService;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class Permissionimpl implements PermissionService {

    final PermissionRepository permissionRepository;
    final PermissionMapper permissionMapper;

    // Toggle
    @Override
    public PermissionDto.ToggleResDto toggle(PermissionDto.ToggleSevDto toggleSevDto){
        Permission permission = permissionRepository.findByRoleIdAndPermissionAndFunc(toggleSevDto.getRoleId(), toggleSevDto.getPermission(), toggleSevDto.getFunc()).orElse(null);

        if(permission == null){
            if(toggleSevDto.getActive()){
                return permissionRepository.save(toggleSevDto.toEntity()).toToggleResDto();
            }
        }else{
            permission.setDeleted(!toggleSevDto.getActive());
            return permissionRepository.save(permission).toToggleResDto();
        }

        return PermissionDto.ToggleResDto.builder().id((long)-100).build();
    }

    // List
    @Override
    public List<PermissionDto.ListResDto> list(PermissionDto.ListSevDto listSevDto){
        List<PermissionDto.ListResDto> res = permissionMapper.list(listSevDto);

        return res;
    }
}
