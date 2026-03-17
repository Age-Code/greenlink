package org.example.greenlink.service.impl;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.Quest;
import org.example.greenlink.domain.User;
import org.example.greenlink.dto.QuestDto;
import org.example.greenlink.repository.QuestRepository;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.service.QuestService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestServiceimpl implements QuestService {
    private final QuestRepository questRepository;
    private final UserRepository userRepository;

    @Override
    public List<QuestDto.ListResDto> list(Long userId){
        User u = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(()->new IllegalArgumentException("user not found"));

        List<Quest> quests = questRepository.findAllByUserId(userId);

        return quests.stream().map(QuestDto.ListResDto::from).toList();
    }

    @Override
    public QuestDto.DetailResDto detail(Long questId, Long userId){
        User u = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(()->new IllegalArgumentException("user not found"));

        Quest q = questRepository.findByIdAndDeletedFalse(questId)
                .orElseThrow(()->new IllegalArgumentException("quest not found"));

        return QuestDto.DetailResDto.from(q);
    }
}
