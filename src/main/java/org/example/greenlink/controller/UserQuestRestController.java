package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.UserQuestDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.UserQuestService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ReuserUserQuestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RequestMapping("/api/userQuest")
@RestController
public class UserQuestRestController {

    final UserQuestService userQuestService;

    public Long getReqUserQuestId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUserQuest().getId();
    }

    // List
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<List<UserQuestDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userQuestService.list(getReqUserQuestId(principalDetails)));
    }

}
