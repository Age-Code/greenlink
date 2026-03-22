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
    public List<QuestDto.ListResDto> list(Long reqUserId){
        User reqUser = userRepository.findByIdAndDeletedFalse(reqUserId)
                .orElseThrow(()->new IllegalArgumentException("user not found"));

        List<Quest> questList = questRepository.findAllByUserId(reqUserId);

        return questList.stream().map(QuestDto.ListResDto::from).toList();
    }

    @Override
    public QuestDto.DetailResDto detail(Long questId, Long reqUserId){
        User reqUser = userRepository.findByIdAndDeletedFalse(reqUserId)
                .orElseThrow(()->new IllegalArgumentException("user not found"));

        Quest quest = questRepository.findByIdAndDeletedFalse(questId)
                .orElseThrow(()->new IllegalArgumentException("quest not found"));

        return QuestDto.DetailResDto.from(quest);
    }
}
