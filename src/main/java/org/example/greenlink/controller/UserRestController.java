package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.UserDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RequestMapping("/api/user")
@RestController
public class UserRestController {

    final UserService userService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    // Signup
    @PostMapping("/signup")
    public ResponseEntity<UserDto.UserIdResDto> signup(@RequestBody UserDto.SignupReqDto reqDto){
        return ResponseEntity.ok(userService.signup(reqDto));
    }

    // Detail
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<UserDto.DetailResDto> detail(@AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userService.detail(getReqUserId(principalDetails)));
    }

    // Update
    @PreAuthorize("hasRole('USER')")
    @PutMapping("")
    public ResponseEntity<UserDto.UserIdResDto> update(@RequestBody UserDto.UpdateReqDto reqDto, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userService.update(reqDto, getReqUserId(principalDetails)));
    }
}
