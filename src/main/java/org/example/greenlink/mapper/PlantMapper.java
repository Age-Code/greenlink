package org.example.greenlink.mapper;

import org.example.greenlink.dto.PlantDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PlantMapper {
    List<PlantDto.ListResDto> list(@Param("listReqDto") PlantDto.ListReqDto listReqDto);
}
