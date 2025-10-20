package org.example.greenlink.mapper.admin;

import org.example.greenlink.dto.admin.NoticeDto;

import java.util.List;

public interface NoticeMapper {
    NoticeDto.DetailResDto detail(NoticeDto.DetailSevDto detailSevDto);
    List<NoticeDto.ListResDto> list(NoticeDto.ListSevDto listSevDto);
}
