package com.designstudio.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.designstudio.system.domain.SysAdmin;
import com.designstudio.system.mapper.SysAdminMapper;
import com.designstudio.system.service.ISysAdminService;
import org.springframework.stereotype.Service;

/**
 * 后台用户 Service 实现
 */
@Service
public class SysAdminServiceImpl extends ServiceImpl<SysAdminMapper, SysAdmin> implements ISysAdminService {

    @Override
    public SysAdmin getByUsername(String username) {
        return getOne(new LambdaQueryWrapper<SysAdmin>()
                .eq(SysAdmin::getUsername, username)
                .eq(SysAdmin::getDelFlag, 0));
    }
}
