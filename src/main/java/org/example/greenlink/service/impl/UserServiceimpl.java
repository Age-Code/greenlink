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
    public UserDto.UserIdResDto signup(UserDto.SignupReqDto reqDto){

        User user = userRepository.findByUsername(reqDto.getUsername()).orElse(null);
        if(user != null) {
            throw new RuntimeException("Already exist");
        }

        reqDto.setPassword(bCryptPasswordEncoder.encode(reqDto.getPassword()));
        user = userRepository.save(reqDto.toEntity());

        return UserDto.UserIdResDto.from(user);
    }

    // Detail
    @Override
    public UserDto.DetailResDto detail(Long reqUserId){
        User user = userRepository.findById(reqUserId).orElseThrow(() -> new EntityNotFoundException("User Detail Error"));

        return UserDto.DetailResDto.from(user);
    }

    // Update
    @Override
    @Transactional
    public UserDto.UserIdResDto update(UserDto.UpdateReqDto reqDto, Long reqUserId){
        User user = userRepository.findById(reqUserId).orElseThrow(() -> new EntityNotFoundException("User Update Error"));

        if(StringUtils.hasText(reqDto.getNickname()) && !reqDto.getNickname().equals(user.getNickname())){
            user.setNickname(reqDto.getNickname());
        }
        if(StringUtils.hasText(reqDto.getPhoneNumber()) && !reqDto.getPhoneNumber().equals(user.getPhoneNumber())){
            user.setPhoneNumber(reqDto.getPhoneNumber());
        }
        if(StringUtils.hasText(reqDto.getAddress()) && !reqDto.getAddress().equals(user.getAddress())){
            user.setAddress(reqDto.getAddress());
        }

        return UserDto.UserIdResDto.from(user);
    }

}
