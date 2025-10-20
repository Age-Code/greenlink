package org.example.greenlink.controller.admin;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.admin.RoleDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.admin.RoleService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/role")
@RestController
public class RoleRestController {

    final RoleService roleService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    @PreAuthorize("hasRole('USER')")
    @PostMapping("")
    public ResponseEntity<RoleDto.CreateResDto> create(@RequestBody RoleDto.CreateReqDto createReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        RoleDto.CreateSevDto createSevDto = RoleDto.CreateSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        createSevDto = (RoleDto.CreateSevDto) createSevDto.afterBuild(createReqDto);

        return ResponseEntity.ok(roleService.create(createSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/detail")
    public ResponseEntity<RoleDto.DetailResDto> detail(RoleDto.DetailReqDto detailReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        RoleDto.DetailSevDto detailSevDto = RoleDto.DetailSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        detailSevDto = (RoleDto.DetailSevDto) detailSevDto.afterBuild(detailReqDto);

        return ResponseEntity.ok(roleService.detail(detailSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/list")
    public ResponseEntity<List<RoleDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails) {

        RoleDto.ListSevDto listSevDto = RoleDto.ListSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();

        return ResponseEntity.ok(roleService.list(listSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @PutMapping("")
    public ResponseEntity<Void> update(@RequestBody RoleDto.UpdateReqDto updateReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        RoleDto.UpdateSevDto updateSevDto = RoleDto.UpdateSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        updateSevDto = (RoleDto.UpdateSevDto) updateSevDto.afterBuild(updateReqDto);
        roleService.update(updateSevDto);

        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PreAuthorize("hasRole('USER')")
    @DeleteMapping("")
    public ResponseEntity<Void> delete(@RequestBody RoleDto.DeleteReqDto deleteReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        RoleDto.DeleteSevDto deleteSevDto = RoleDto.DeleteSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        deleteSevDto = (RoleDto.DeleteSevDto) deleteSevDto.afterBuild(deleteReqDto);
        roleService.delete(deleteSevDto);

        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
