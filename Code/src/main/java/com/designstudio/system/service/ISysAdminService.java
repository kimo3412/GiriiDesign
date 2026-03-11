package com.designstudio.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.designstudio.system.domain.SysAdmin;

/**
 * 后台用户 Service 接口
 */
public interface ISysAdminService extends IService<SysAdmin> {

    /**
     * 根据用户名查询后台用户
     */
    SysAdmin getByUsername(String username);
}
