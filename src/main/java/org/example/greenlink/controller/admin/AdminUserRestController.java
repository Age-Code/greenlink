package org.example.greenlink.controller.admin;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.admin.AdminUserDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.admin.AdminUserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/adminUser")
@RestController
public class AdminUserRestController {

    final AdminUserService adminUserService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    @PreAuthorize("hasRole('USER')")
    @PostMapping("")
    public ResponseEntity<AdminUserDto.CreateResDto> create(@RequestBody AdminUserDto.CreateReqDto createReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        AdminUserDto.CreateSevDto createSevDto = AdminUserDto.CreateSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        createSevDto = (AdminUserDto.CreateSevDto) createSevDto.afterBuild(createReqDto);

        return ResponseEntity.ok(adminUserService.create(createSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/detail")
    public ResponseEntity<AdminUserDto.DetailResDto> detail(AdminUserDto.DetailReqDto detailReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        AdminUserDto.DetailSevDto detailSevDto = AdminUserDto.DetailSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        detailSevDto = (AdminUserDto.DetailSevDto) detailSevDto.afterBuild(detailReqDto);

        return ResponseEntity.ok(adminUserService.detail(detailSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/list")
    public ResponseEntity<List<AdminUserDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails) {

        AdminUserDto.ListSevDto listSevDto = AdminUserDto.ListSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();

        return ResponseEntity.ok(adminUserService.list(listSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @PutMapping("")
    public ResponseEntity<Void> update(@RequestBody AdminUserDto.UpdateReqDto updateReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        AdminUserDto.UpdateSevDto updateSevDto = AdminUserDto.UpdateSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        updateSevDto = (AdminUserDto.UpdateSevDto) updateSevDto.afterBuild(updateReqDto);
        adminUserService.update(updateSevDto);

        return ResponseEntity.status(HttpStatus.OK).build();
    }

//    @PreAuthorize("hasAdminUser('USER')")
//    @DeleteMapping("")
//    public ResponseEntity<Void> delete(@RequestBody AdminUserDto.DeleteReqDto deleteReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {
//
//        AdminUserDto.DeleteSevDto deleteSevDto = AdminUserDto.DeleteSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
//        deleteSevDto = (AdminUserDto.DeleteSevDto) deleteSevDto.afterBuild(deleteReqDto);
//        adminUserService.delete(deleteSevDto);
//
//        return ResponseEntity.status(HttpStatus.OK).build();
//    }
}
