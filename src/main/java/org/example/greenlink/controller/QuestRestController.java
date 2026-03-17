package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.QuestDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.QuestService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/quest")
@RestController
public class QuestRestController {

    final QuestService questService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    // 6.1 퀘스트 목록 조회
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<List<QuestDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails) {
        return ResponseEntity.ok(questService.list(getReqUserId(principalDetails)));
    }

    // 6.2 퀘스트 상세 표시
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/{questId}")
    public ResponseEntity<QuestDto.DetailResDto> detail(@PathVariable Long questId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(questService.detail(questId, getReqUserId(principalDetails)));
    }
}
