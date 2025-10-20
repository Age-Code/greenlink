package org.example.greenlink.service.user;

import org.example.greenlink.dto.user.UserDto;
import org.springframework.stereotype.Service;

@Service
public interface UserService {
    UserDto.SignupResDto signup(UserDto.SignupReqDto signupReqDto);
}
