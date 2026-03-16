package com.designstudio.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.order.domain.DsOrder;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DsOrderMapper extends BaseMapper<DsOrder> {
}
