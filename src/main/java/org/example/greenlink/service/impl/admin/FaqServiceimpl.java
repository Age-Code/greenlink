package org.example.greenlink.service.impl.admin;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.admin.Faq;
import org.example.greenlink.dto.admin.FaqDto;
import org.example.greenlink.dto.admin.RoleUserDto;
import org.example.greenlink.mapper.admin.FaqMapper;
import org.example.greenlink.repository.admin.FaqRepository;
import org.example.greenlink.service.admin.FaqService;
import org.example.greenlink.service.admin.RoleUserService;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class FaqServiceimpl implements FaqService {

    final String permission = "faq";
    final RoleUserService roleUserService;

    final FaqRepository faqRepository;
    final FaqMapper faqMapper;

    // Create
    @Override
    public FaqDto.CreateResDto create(FaqDto.CreateSevDto createSevDto) {
        roleUserService.permit(RoleUserDto.PermitSevDto.builder().reqUserId(createSevDto.getReqUserId()).permission(permission).func(120).build());

        FaqDto.CreateResDto res = faqRepository.save(createSevDto.toEntity()).toCreateResDto();

        return res;
    }

    // Detail
    @Override
    public FaqDto.DetailResDto detail(FaqDto.DetailSevDto detailSevDto){
        roleUserService.permit(RoleUserDto.PermitSevDto.builder().reqUserId(detailSevDto.getReqUserId()).permission(permission).func(150).build());

        FaqDto.DetailResDto res = faqMapper.detail(detailSevDto);

        return res;
    }

    // List
    @Override
    public List<FaqDto.ListResDto> list(FaqDto.ListSevDto listSevDto){

        List<FaqDto.ListResDto> res = faqMapper.list(listSevDto);

        return res;
    }

    // Update
    @Override
    public void update(FaqDto.UpdateSevDto updateSevDto){
        roleUserService.permit(RoleUserDto.PermitSevDto.builder().reqUserId(updateSevDto.getReqUserId()).permission(permission).func(180).build());

        Faq faq = faqRepository.findById(updateSevDto.getId()).orElse(null);
        if(faq == null){
            throw new RuntimeException("no data");
        }

        if(updateSevDto.getTitle() != null){
            faq.setTitle(updateSevDto.getTitle());
        }
        if(updateSevDto.getContent() != null){
            faq.setContent(updateSevDto.getContent());
        }

        faqRepository.save(faq);
    }

    // Delete
    @Override
    public void delete(FaqDto.DeleteSevDto deleteSevDto){
        roleUserService.permit(RoleUserDto.PermitSevDto.builder().reqUserId(deleteSevDto.getReqUserId()).permission(permission).func(200).build());

        Faq faq = faqRepository.findById(deleteSevDto.getId()).orElse(null);
        if(faq == null){
            throw new RuntimeException("no data");
        }

        faq.setDeleted(true);

        faqRepository.save(faq);
    }
}
