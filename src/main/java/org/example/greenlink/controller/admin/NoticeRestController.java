package org.example.greenlink.controller.admin;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.dto.admin.NoticeDto;
import org.example.greenlink.security.PrincipalDetails;
import org.example.greenlink.service.admin.NoticeService;
import org.example.greenlink.util.FileUpload;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RequiredArgsConstructor
@RequestMapping("/api/notice")
@RestController
public class NoticeRestController {

    final NoticeService noticeService;

    public Long getReqUserId(PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            return null;
        }

        return principalDetails.getUser().getId();
    }

    @PostMapping("/uploadFile")
    public String uploadFile(MultipartFile file) throws IOException {
        return FileUpload.upload(file);
    }

    @PreAuthorize("hasRole('USER')")
    @PostMapping("")
    public ResponseEntity<NoticeDto.CreateResDto> create(@RequestBody NoticeDto.CreateReqDto createReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        NoticeDto.CreateSevDto createSevDto = NoticeDto.CreateSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        createSevDto = (NoticeDto.CreateSevDto) createSevDto.afterBuild(createReqDto);

        return ResponseEntity.ok(noticeService.create(createSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/detail")
    public ResponseEntity<NoticeDto.DetailResDto> detail(NoticeDto.DetailReqDto detailReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        NoticeDto.DetailSevDto detailSevDto = NoticeDto.DetailSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        detailSevDto = (NoticeDto.DetailSevDto) detailSevDto.afterBuild(detailReqDto);

        return ResponseEntity.ok(noticeService.detail(detailSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/list")
    public ResponseEntity<List<NoticeDto.ListResDto>> list(@AuthenticationPrincipal PrincipalDetails principalDetails) {

        NoticeDto.ListSevDto listSevDto = NoticeDto.ListSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();

        return ResponseEntity.ok(noticeService.list(listSevDto));
    }

    @PreAuthorize("hasRole('USER')")
    @PutMapping("")
    public ResponseEntity<Void> update(@RequestBody NoticeDto.UpdateReqDto updateReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        NoticeDto.UpdateSevDto updateSevDto = NoticeDto.UpdateSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        updateSevDto = (NoticeDto.UpdateSevDto) updateSevDto.afterBuild(updateReqDto);
        noticeService.update(updateSevDto);

        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PreAuthorize("hasRole('USER')")
    @DeleteMapping("")
    public ResponseEntity<Void> delete(@RequestBody NoticeDto.DeleteReqDto deleteReqDto, @AuthenticationPrincipal PrincipalDetails principalDetails) {

        NoticeDto.DeleteSevDto deleteSevDto = NoticeDto.DeleteSevDto.builder().reqUserId(getReqUserId(principalDetails)).build();
        deleteSevDto = (NoticeDto.DeleteSevDto) deleteSevDto.afterBuild(deleteReqDto);
        noticeService.delete(deleteSevDto);

        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
