package org.example.greenlink.service;

import org.example.greenlink.dto.UserQuestDto;
import org.example.greenlink.security.PrincipalDetails;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@Service
public interface UserQuestService {
    List<UserQuestDto.ListResDto> list(Long reqUserId);
    UserQuestDto.DetailResDto detail(Long userQuestId, Long reqUserId);
    UserQuestDto.ClaimResDto claim(Long userQuestId, Long reqUserId);
}
