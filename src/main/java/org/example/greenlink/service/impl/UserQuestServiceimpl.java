package org.example.greenlink.service.impl;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.*;
import org.example.greenlink.dto.QuestDto;
import org.example.greenlink.dto.UserQuestDto;
import org.example.greenlink.exception.NoMatchingDataException;
import org.example.greenlink.exception.NoPermissionException;
import org.example.greenlink.repository.UserPlantItemRepository;
import org.example.greenlink.repository.UserQuestRepository;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.service.UserQuestService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserQuestServiceimpl implements UserQuestService {
    private final UserQuestRepository userQuestRepository;
    private final UserRepository userRepository;
    private final UserPlantItemRepository userPlantItemRepository;

    @Override
    public List<UserQuestDto.ListResDto> list(Long reqUserId) {
        User user = userRepository.findByIdAndDeletedFalse(reqUserId).orElseThrow(() -> new EntityNotFoundException("UserQuest List Error: 존재하지 않는 User입니다."));

        List<UserQuest> userQuestList = userQuestRepository.findByUserAndDeletedFalse(user);

        return userQuestList.stream().map(UserQuestDto.ListResDto::from).toList();
    }

    @Override
    public UserQuestDto.DetailResDto detail(Long userQuestId, Long reqUserId){
        UserQuest userQuest = userQuestRepository.findByIdAndDeletedFalse(userQuestId).orElseThrow(() -> new EntityNotFoundException("UserQuest Detail Error: 존재하지 않는 User입니다."));

        if(!userQuest.getUser().getId().equals(reqUserId)){
            throw new NoPermissionException("UserQuest Detail Error: 접근 권한이 없습니다.");
        }

        return UserQuestDto.DetailResDto.from(userQuest);
    }

    @Override
    public UserQuestDto.ClaimResDto claim(Long userQuestId, Long reqUserId){
        User user = userRepository.findByIdAndDeletedFalse(reqUserId).orElseThrow(() -> new EntityNotFoundException("UserQuest Claim Error: 존재하지 않는 User입니다."));
        UserQuest userQuest = userQuestRepository.findByIdAndDeletedFalse(userQuestId).orElseThrow(() -> new EntityNotFoundException("UserQuest Claim Error: 존재하지 않는 User입니다."));

        if(!userQuest.getUser().getId().equals(reqUserId)){
            throw new NoPermissionException("UserQuest Claim Error: 접근 권한이 없습니다.");
        }

        if(!userQuest.getState().equals(DomainEnum.State.COMPLETED)){
            throw new NoMatchingDataException("UserQuest Claim Error: 완료되지 않은 퀘스트입니다.");
        }

        userQuest.setState(DomainEnum.State.CLAIMED);

        UserPlantItem userPlantItem = UserPlantItem.of(user, null, userQuest.getQuest().getRewardItem());

        return UserQuestDto.ClaimResDto.from(userQuest, userPlantItemRepository.save(userPlantItem).getId());
    }
}
