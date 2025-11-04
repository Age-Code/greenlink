package org.example.greenlink.service;

import org.example.greenlink.dto.UserDto;
import org.springframework.stereotype.Service;

@Service
public interface UserService {
    UserDto.SignupResDto signup(UserDto.SignupReqDto signupReqDto);
}
