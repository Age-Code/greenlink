package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.AttendDto;
import org.example.greenlink.dto.UserPlantItemDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.UserPlantItemService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/userPlantItem")
@RestController
public class UserPlantItemRestController {
    private final UserPlantItemService userPlantItemService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    //4.1 인벤토리 목록 조회/필터 → 필터링 고민 중 프론트 or 백 → 필터는 나중에
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<List<UserPlantItemDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantItemService.list(getReqUserId(principalDetails)));
    }

    //4.2 아이템 상세
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/{userPlantItemId}")
    public ResponseEntity<UserPlantItemDto.DetailResDto> detailItem(@PathVariable Long userPlantItemId,
                                                                  @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantItemService.detailItem(userPlantItemId, getReqUserId(principalDetails)));
    }

    //4.3 아이템 사용/해제
    @PreAuthorize("hasRole('USER')")
    @PutMapping("/{userPlantItemId}")
    public ResponseEntity<UserPlantItemDto.UpdateResDto> updateItem(@PathVariable Long userPlantItemId,
                                                                    @RequestBody UserPlantItemDto.UpdateReqDto req,
                                                                    @AuthenticationPrincipal PrincipalDetails principalDetails){
        return ResponseEntity.ok(userPlantItemService.updateItem(userPlantItemId, req, getReqUserId(principalDetails)));
    }
}
