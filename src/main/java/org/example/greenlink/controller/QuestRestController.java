package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.QuestDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.QuestService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RequestMapping("/api/quest")
@RestController
public class QuestRestController {

    final QuestService questService;

    public Long getReqQuestId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getQuest().getId();
    }

    // List
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<List<QuestDto.ListResDto>> list(){
        return ResponseEntity.ok(questService.list());
    }

    // Detail
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/{questId}")
    public ResponseEntity<QuestDto.DetailResDto> detail(@PathVariable Long questId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(questService.detail(questId, getReqQuestId(principalDetails)));
    }
}
