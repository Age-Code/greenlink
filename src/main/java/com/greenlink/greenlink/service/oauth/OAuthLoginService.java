package com.greenlink.greenlink.service.oauth;

import com.greenlink.greenlink.domain.user.User;
import com.greenlink.greenlink.dto.AuthDto;
import com.greenlink.greenlink.repository.UserRepository;
import com.greenlink.greenlink.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class OAuthLoginService {

    private final KakaoOAuthClient kakaoOAuthClient;
    private final GoogleOAuthClient googleOAuthClient;
    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public AuthDto.LoginResDto loginWithKakao(AuthDto.OAuthLoginReqDto request) {
        OAuthUserInfo userInfo = kakaoOAuthClient.getUserInfo(
                request.getCode(),
                request.getRedirectUri()
        );

        User user = findOrCreateOAuthUser(userInfo);

        return createLoginResponse(user);
    }

    @Transactional
    public AuthDto.LoginResDto loginWithGoogle(AuthDto.OAuthLoginReqDto request) {
        OAuthUserInfo userInfo = googleOAuthClient.getUserInfo(
                request.getCode(),
                request.getRedirectUri()
        );

        User user = findOrCreateOAuthUser(userInfo);

        return createLoginResponse(user);
    }

    private User findOrCreateOAuthUser(OAuthUserInfo userInfo) {
        return userRepository
                .findByProviderAndProviderIdAndDeletedFalse(
                        userInfo.getProvider(),
                        userInfo.getProviderId()
                )
                .orElseGet(() -> createOAuthUser(userInfo));
    }

    private User createOAuthUser(OAuthUserInfo userInfo) {
        String socialPassword = passwordEncoder.encode(
                "SOCIAL_LOGIN_" + userInfo.getProvider() + "_" + userInfo.getProviderId()
        );

        User user = User.createOAuthUser(
                userInfo.getEmail(),
                socialPassword,
                userInfo.getNickname(),
                userInfo.getProvider(),
                userInfo.getProviderId(),
                userInfo.getProfileImageUrl()
        );

        return userRepository.save(user);
    }

    private AuthDto.LoginResDto createLoginResponse(User user) {
        String accessToken = jwtTokenProvider.createAccessToken(
                user.getId(),
                user.getEmail(),
                user.getRole().name()
        );

        return AuthDto.LoginResDto.of(accessToken, user);
    }
}