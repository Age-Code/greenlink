package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.AttendDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.AttendService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/attend")
@RestController
public class AttendRestController {

    final AttendService attendService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    // Today
    @PostMapping("/today")
    public ResponseEntity<AttendDto.TodayResDto> today(@AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(attendService.today(getReqUserId(principalDetails)));
    }

    // list
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<AttendDto.ListResDto> list(@RequestParam("year") int year, @RequestParam("month") int month, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(attendService.list(year, month, getReqUserId  (principalDetails)));
    }
}
