package org.example.greenlink.service.admin;

import org.example.greenlink.dto.admin.RoleUserDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface RoleUserService {
    void permit(RoleUserDto.PermitSevDto permitSevDto);
    void add(RoleUserDto.AddUserSevDto addUserSevDto);
    List<RoleUserDto.ListResDto> userList(RoleUserDto.ListSevDto listSevDto);
    List<RoleUserDto.AddListResDto> addUserList(RoleUserDto.AddListSevDto addListSevDto);
    List<RoleUserDto.ListResDto> roleList(RoleUserDto.ListSevDto listSevDto);
    List<RoleUserDto.AddListResDto> addRoleList(RoleUserDto.AddListSevDto addListSevDto);
    void delete(RoleUserDto.DeleteSevDto deleteSevDto);
}
