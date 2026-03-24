package com.designstudio.customer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.customer.domain.DsAddress;
import org.apache.ibatis.annotations.Mapper;

/**
 * 收货地址 Mapper 接口
 */
@Mapper
public interface DsAddressMapper extends BaseMapper<DsAddress> {
}
