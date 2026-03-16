package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.UserPlantDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.UserPlantService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RequestMapping("/api/userPlant")
@RestController
public class UserPlantRestController {

    final UserPlantService userPlantService;

    public Long getReqUserPlantId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    // 나의 식물 생성
    @PreAuthorize("hasRole('USER')")
    @PostMapping("")
    public ResponseEntity<UserPlantDto.UserPlantIdResDto> create(@RequestBody UserPlantDto.CreateReqDto createReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.create(createReqDto, getReqUserPlantId(principalDetails)));
    }

    // 나의 식물 목록 조회
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<List<UserPlantDto.ListResDto>> list(@RequestBody UserPlantDto.ListReqDto listReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.list(listReqDto, getReqUserPlantId(principalDetails)));
    }

    // Detail
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/{userPlantId}")
    public ResponseEntity<UserPlantDto.DetailResDto> detail(@PathVariable Long userPlantId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.detail(userPlantId, getReqUserPlantId(principalDetails)));
    }

    // Update
    @PreAuthorize("hasRole('USER')")
    @PutMapping("/{userPlantId}")
    public ResponseEntity<UserPlantDto.UserPlantIdResDto> update(@PathVariable Long userPlantId, @RequestBody UserPlantDto.UpdateReqDto updateReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.update(userPlantId, updateReqDto, getReqUserPlantId(principalDetails)));
    }

    // Harvest
    @PreAuthorize("hasRole('USER')")
    @PutMapping("/{userPlantId}/harvest")
    public ResponseEntity<UserPlantDto.HarvestResDto> harvest(@PathVariable Long userPlantId, @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantService.harvest(userPlantId, getReqUserPlantId(principalDetails)));
    }
}
