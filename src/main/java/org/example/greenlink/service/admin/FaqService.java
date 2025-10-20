package org.example.greenlink.service.admin;

import org.example.greenlink.dto.admin.FaqDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface FaqService {
    FaqDto.CreateResDto create(FaqDto.CreateSevDto createSevDto);
    FaqDto.DetailResDto detail(FaqDto.DetailSevDto detailSevDto);
    List<FaqDto.ListResDto> list(FaqDto.ListSevDto listSevDto);
    void update(FaqDto.UpdateSevDto updateSevDto);
    void delete(FaqDto.DeleteSevDto deleteSevDto);
}
