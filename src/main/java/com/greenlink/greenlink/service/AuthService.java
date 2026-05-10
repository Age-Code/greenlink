package com.greenlink.greenlink.service;

import com.greenlink.greenlink.domain.item.Item;
import com.greenlink.greenlink.domain.item.UserItem;
import com.greenlink.greenlink.domain.quest.Quest;
import com.greenlink.greenlink.domain.quest.QuestType;
import com.greenlink.greenlink.domain.quest.UserQuest;
import com.greenlink.greenlink.domain.user.User;
import com.greenlink.greenlink.dto.AuthDto;
import com.greenlink.greenlink.repository.ItemRepository;
import com.greenlink.greenlink.repository.QuestRepository;
import com.greenlink.greenlink.repository.UserItemRepository;
import com.greenlink.greenlink.repository.UserQuestRepository;
import com.greenlink.greenlink.repository.UserRepository;
import com.greenlink.greenlink.security.JwtTokenProvider;
import com.greenlink.greenlink.service.oauth.OAuthUserInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private static final String DEFAULT_SEED_NAME = "바질 씨앗";
    private static final String DEFAULT_POT_NAME = "기본 화분";

    private final UserRepository userRepository;
    private final ItemRepository itemRepository;
    private final UserItemRepository userItemRepository;
    private final QuestRepository questRepository;
    private final UserQuestRepository userQuestRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @Transactional
    public AuthDto.SignupResDto signup(AuthDto.SignupReqDto request) {
        validateDuplicateEmail(request.getEmail());

        String encodedPassword = passwordEncoder.encode(request.getPassword());

        User user = User.createUser(
                request.getEmail(),
                encodedPassword,
                request.getNickname()
        );

        User savedUser = userRepository.save(user);

        List<UserItem> grantedItems = grantDefaultItems(savedUser);

        createAchievementUserQuests(savedUser);

        return AuthDto.SignupResDto.of(savedUser, grantedItems);
    }

    public AuthDto.LoginResDto login(AuthDto.LoginReqDto request) {
        User user = userRepository.findByEmailAndDeletedFalse(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("이메일 또는 비밀번호가 올바르지 않습니다."));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("이메일 또는 비밀번호가 올바르지 않습니다.");
        }

        String accessToken = jwtTokenProvider.createAccessToken(
                user.getId(),
                user.getEmail(),
                user.getRole().name()
        );

        return AuthDto.LoginResDto.of(accessToken, user);
    }

    @Transactional
    public AuthDto.LoginResDto oauthLogin(OAuthUserInfo userInfo) {
        User user = userRepository
                .findByProviderAndProviderIdAndDeletedFalse(
                        userInfo.getProvider(),
                        userInfo.getProviderId()
                )
                .orElseGet(() -> createOAuthUserFromOAuthInfo(userInfo));

        String accessToken = jwtTokenProvider.createAccessToken(
                user.getId(),
                user.getEmail(),
                user.getRole().name()
        );

        return AuthDto.LoginResDto.of(accessToken, user);
    }

    private User createOAuthUserFromOAuthInfo(OAuthUserInfo userInfo) {
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

        User savedUser = userRepository.save(user);

        grantDefaultItems(savedUser);

        createAchievementUserQuests(savedUser);

        return savedUser;
    }

    private void validateDuplicateEmail(String email) {
        if (userRepository.existsByEmailAndDeletedFalse(email)) {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }
    }

    private List<UserItem> grantDefaultItems(User user) {
        Item basilSeed = itemRepository.findByNameAndDeletedFalse(DEFAULT_SEED_NAME)
                .orElseThrow(() -> new IllegalStateException("기본 지급 아이템인 바질 씨앗이 등록되어 있지 않습니다."));

        Item basicPot = itemRepository.findByNameAndDeletedFalse(DEFAULT_POT_NAME)
                .orElseThrow(() -> new IllegalStateException("기본 지급 아이템인 기본 화분이 등록되어 있지 않습니다."));

        List<UserItem> grantedItems = new ArrayList<>();

        grantedItems.add(userItemRepository.save(UserItem.createOwned(user, basilSeed)));
        grantedItems.add(userItemRepository.save(UserItem.createOwned(user, basicPot)));

        return grantedItems;
    }

    private void createAchievementUserQuests(User user) {
        List<Quest> achievementQuests =
                questRepository.findAllByQuestTypeAndActiveTrueAndDeletedFalse(QuestType.ACHIEVEMENT);

        LocalDateTime now = LocalDateTime.now();

        for (Quest quest : achievementQuests) {
            UserQuest userQuest = UserQuest.create(user, quest, now);
            userQuestRepository.save(userQuest);
        }
    }
}