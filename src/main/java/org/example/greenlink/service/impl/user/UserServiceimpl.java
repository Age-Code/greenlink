package org.example.greenlink.service.impl.user;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.user.User;
import org.example.greenlink.dto.user.UserDto;
import org.example.greenlink.repository.user.UserRepository;
import org.example.greenlink.service.user.UserService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class UserServiceimpl implements UserService {

    final UserRepository userRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;

    // Signup
    @Override
    public UserDto.SignupResDto signup(UserDto.SignupReqDto signupReqDto){

        User user = userRepository.findByUsername(signupReqDto.getUsername()).orElse(null);
        if(user != null) {
            throw new RuntimeException("Already exist");
        }

        signupReqDto.setPassword(bCryptPasswordEncoder.encode(signupReqDto.getPassword()));
        user = userRepository.save(signupReqDto.toEntity());

        return user.toSignupResDto();
    }

}
