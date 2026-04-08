package com.designstudio.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.designstudio.system.controller.AdminController;
import com.designstudio.system.controller.SysAdminController;
import com.designstudio.system.domain.SysAdmin;

import java.util.List;

/**
 * 后台用户 Service 接口
 */
public interface ISysAdminService extends IService<SysAdmin> {

    SysAdmin getByUsername(String username);

    List<SysAdmin> listAdmins();

    SysAdminController.AdminDetailVO getAdminDetail(Long id);

    void addAdmin(SysAdminController.AdminSaveDTO dto);

    void updateAdmin(Long id, SysAdminController.AdminSaveDTO dto);

    void deleteAdmin(Long id);
}
