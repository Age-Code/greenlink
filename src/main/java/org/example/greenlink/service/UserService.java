package org.example.greenlink.service;

import org.example.greenlink.dto.UserDto;
import org.springframework.stereotype.Service;

@Service
public interface UserService {
    UserDto.UserIdResDto signup(UserDto.SignupReqDto signupReqDto);
    UserDto.DetailResDto detail(Long requestUserId);
    UserDto.UserIdResDto update(UserDto.UpdateReqDto updateReqDto, Long requestUserId);
}
