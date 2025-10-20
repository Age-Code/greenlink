package org.example.greenlink.controller.admin;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.admin.FaqDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.admin.FaqService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/faq")
@RestController
public class FaqRestController {

    final FaqService faqService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    @PreAuthorize("hasRole('USER')")
    @PostMapping("")
    public ResponseEntity<FaqDto.CreateResDto> create(@RequestBody FaqDto.CreateReqDto createReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        FaqDto.CreateSevDto createSevDto = FaqDto.CreateSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        createSevDto = (FaqDto.CreateSevDto) createSevDto.afterBuild(createReqDto);

        return ResponseEntity.ok(faqService.create(createSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/detail")
    public ResponseEntity<FaqDto.DetailResDto> detail(FaqDto.DetailReqDto detailReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        FaqDto.DetailSevDto detailSevDto = FaqDto.DetailSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        detailSevDto = (FaqDto.DetailSevDto) detailSevDto.afterBuild(detailReqDto);

        return ResponseEntity.ok(faqService.detail(detailSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/list")
    public ResponseEntity<List<FaqDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails) {

        FaqDto.ListSevDto listSevDto = FaqDto.ListSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();

        return ResponseEntity.ok(faqService.list(listSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @PutMapping("")
    public ResponseEntity<Void> update(@RequestBody FaqDto.UpdateReqDto updateReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        FaqDto.UpdateSevDto updateSevDto = FaqDto.UpdateSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        updateSevDto = (FaqDto.UpdateSevDto) updateSevDto.afterBuild(updateReqDto);
        faqService.update(updateSevDto);

        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PreAuthorize("hasRole('USER')")
    @DeleteMapping("")
    public ResponseEntity<Void> delete(@RequestBody FaqDto.DeleteReqDto deleteReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        FaqDto.DeleteSevDto deleteSevDto = FaqDto.DeleteSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        deleteSevDto = (FaqDto.DeleteSevDto) deleteSevDto.afterBuild(deleteReqDto);
        faqService.delete(deleteSevDto);

        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
