package org.example.greenlink.service.impl;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.User;
import org.example.greenlink.dto.UserDto;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.service.UserService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@RequiredArgsConstructor
@Service
public class UserServiceimpl implements UserService {

    final UserRepository userRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;

    // Signup
    @Override
    public UserDto.UserIdResDto signup(UserDto.SignupReqDto signupReqDto){

        User user = userRepository.findByUsername(signupReqDto.getUsername()).orElse(null);
        if(user != null) {
            throw new RuntimeException("Already exist");
        }

        signupReqDto.setPassword(bCryptPasswordEncoder.encode(signupReqDto.getPassword()));
        user = userRepository.save(signupReqDto.toEntity());

        return UserDto.UserIdResDto.toUserIdResDto(user);
    }

    // Detail
    @Override
    public UserDto.DetailResDto detail(Long requestUserId){
        User user = userRepository.findById(requestUserId).orElseThrow(() -> new EntityNotFoundException("User Detail Error"));

        return UserDto.DetailResDto.from(user);
    }

    // Update
    @Override
    @Transactional
    public UserDto.UserIdResDto update(UserDto.UpdateReqDto updateReqDto, Long requestUserId){
        User user = userRepository.findById(requestUserId).orElseThrow(() -> new EntityNotFoundException("User Update Error"));

        if(StringUtils.hasText(updateReqDto.getNickname()) && !updateReqDto.getNickname().equals(user.getNickname())){
            user.setNickname(updateReqDto.getNickname());
        }
        if(StringUtils.hasText(updateReqDto.getPhoneNumber()) && !updateReqDto.getPhoneNumber().equals(user.getPhoneNumber())){
            user.setPhoneNumber(updateReqDto.getPhoneNumber());
        }
        if(StringUtils.hasText(updateReqDto.getAddress()) && !updateReqDto.getAddress().equals(user.getAddress())){
            user.setAddress(updateReqDto.getAddress());
        }

        return UserDto.UserIdResDto.toUserIdResDto(user);
    }

}
