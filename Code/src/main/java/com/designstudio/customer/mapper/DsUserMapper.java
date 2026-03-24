package com.designstudio.customer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.customer.domain.DsUser;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DsUserMapper extends BaseMapper<DsUser> {
}
