package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.UserPlantDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.UserPlantService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/userPlant")
@RestController
public class UserPlantRestController {

    final UserPlantService userPlantService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    // 나의 식물 생성
    @PreAuthorize("hasRole('USER')")
    @PostMapping("")
    public ResponseEntity<UserPlantDto.UserPlantIdResDto> create(@RequestBody UserPlantDto.CreateReqDto reqDto, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.create(reqDto, getReqUserId(principalDetails)));
    }

    // 나의 식물 목록 조회
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<List<UserPlantDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.list(getReqUserId(principalDetails)));
    }

    // 나의 식물 상세 조회
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/{userPlantId}")
    public ResponseEntity<UserPlantDto.DetailResDto> detail(@PathVariable Long userPlantId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.detail(userPlantId, getReqUserId(principalDetails)));
    }

    // 나의 식물 별명 수정
    @PreAuthorize("hasRole('USER')")
    @PutMapping("/{userPlantId}")
    public ResponseEntity<UserPlantDto.UserPlantIdResDto> update(@PathVariable Long userPlantId, @RequestBody UserPlantDto.UpdateReqDto reqDto, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.update(userPlantId, reqDto, getReqUserId(principalDetails)));
    }

    // 수확하기
    @PreAuthorize("hasRole('USER')")
    @PostMapping("/{userPlantId}/harvest")
    public ResponseEntity<UserPlantDto.HarvestResDto> harvest(@PathVariable Long userPlantId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.harvest(userPlantId, getReqUserId(principalDetails)));
    }

    // 물주기
    @PreAuthorize("hasRole('USER')")
    @PostMapping("/{userPlantId}/water")
    public ResponseEntity<UserPlantDto.WaterResDto> water(@PathVariable Long userPlantId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.water(userPlantId, getReqUserId(principalDetails)));
    }

    // 햇볕 쬐기
    @PreAuthorize("hasRole('USER')")
    @PostMapping("/{userPlantId}/light")
    public ResponseEntity<UserPlantDto.LightResDto> light(@PathVariable Long userPlantId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.light(userPlantId, getReqUserId(principalDetails)));
    }
}
