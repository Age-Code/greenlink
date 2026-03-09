package org.example.greenlink.controller;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.PlantDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.PlantService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/plant")
@RestController
public class PlantRestController {

    final PlantService plantService;

    public Long getReqPlantId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    // List
    @PreAuthorize("hasRole('USER')")
    @GetMapping("")
    public ResponseEntity<List<PlantDto.ListResDto>> list(@RequestBody PlantDto.ListReqDto listReqDto){
        return ResponseEntity.ok(plantService.list(listReqDto));
    }

    // Detail
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/{plantId}")
    public ResponseEntity<PlantDto.DetailResDto> detail(@PathVariable Long plantId){
        return ResponseEntity.ok(plantService.detail(plantId));
    }
}
