package com.greenlink.greenlink.service;

import com.greenlink.greenlink.domain.user.User;
import com.greenlink.greenlink.dto.UserDto;
import com.greenlink.greenlink.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    public UserDto.MeResDto getMe(Long userId) {
        User user = findActiveUser(userId);

        return UserDto.MeResDto.from(user);
    }

    @Transactional
    public UserDto.UpdateNicknameResDto updateNickname(
            Long userId,
            UserDto.UpdateNicknameReqDto request
    ) {
        User user = findActiveUser(userId);

        user.updateNickname(request.getNickname());

        return UserDto.UpdateNicknameResDto.from(user);
    }

    private User findActiveUser(Long userId) {
        return userRepository.findById(userId)
                .filter(user -> !user.isDeleted())
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }
}