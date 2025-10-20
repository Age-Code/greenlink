package org.example.greenlink.mapper.admin;

import org.example.greenlink.dto.admin.FaqDto;

import java.util.List;

public interface FaqMapper {
    FaqDto.DetailResDto detail(FaqDto.DetailSevDto detailSevDto);
    List<FaqDto.ListResDto> list(FaqDto.ListSevDto listSevDto);
}
