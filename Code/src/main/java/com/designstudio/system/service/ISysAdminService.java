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

    /**
     * 根据品类ID查询负责该品类的设计师列表
     */
    List<SysAdmin> getDesignersByCategory(Long categoryId);

    /**
     * 获取某设计师负责的品类ID列表
     */
    List<Long> getDesignerCategoryIds(Long adminId);

    /**
     * 更新设计师负责的品类
     */
    void updateDesignerCategories(Long adminId, List<Long> categoryIds);
}
