package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.UserQuestDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.UserQuestService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/userQuest")
@RestController
public class UserQuestRestController {

    final UserQuestService userQuestService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    // 6.3 나의 퀘스트 목록 조회
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<List<UserQuestDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails) {
        return ResponseEntity.ok(userQuestService.list(getReqUserId(principalDetails)));
    }

    // 6.4 나의 퀘스트 상세 표시
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/{userQuestId}")
    public ResponseEntity<UserQuestDto.DetailResDto> detail(@PathVariable Long userQuestId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userQuestService.detail(userQuestId, getReqUserId(principalDetails)));
    }

    // 6.5 퀘스트 보상 수령
    @PreAuthorize("hasRole('USER')")
    @PostMapping("/{userQuestId}/claim")
    public ResponseEntity<UserQuestDto.ClaimResDto> claim(@PathVariable Long userQuestId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userQuestService.claim(userQuestId, getReqUserId(principalDetails)));
    }

}
