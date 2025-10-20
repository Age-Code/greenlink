package org.example.greenlink.service.admin;

import org.example.greenlink.dto.admin.NoticeDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface NoticeService {
    NoticeDto.CreateResDto create(NoticeDto.CreateSevDto createSevDto);
    NoticeDto.DetailResDto detail(NoticeDto.DetailSevDto detailSevDto);
    List<NoticeDto.ListResDto> list(NoticeDto.ListSevDto listSevDto);
    void update(NoticeDto.UpdateSevDto updateSevDto);
    void delete(NoticeDto.DeleteSevDto deleteSevDto);
}
