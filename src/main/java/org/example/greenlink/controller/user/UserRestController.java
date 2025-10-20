package org.example.greenlink.controller.user;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.user.UserDto;
import org.example.greenlink.service.user.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RequestMapping("/api/user")
@RestController
public class UserRestController {

    final UserService userService;

    @PostMapping("/signup")
    public ResponseEntity<UserDto.SignupResDto> signup(@RequestBody UserDto.SignupReqDto signupReqDto){
        return ResponseEntity.ok(userService.signup(signupReqDto));
    }
}
