package com.designstudio.system.service;

import com.designstudio.system.controller.AdminController;

import java.util.List;

/**
 * 管理员信息 Service（权限查询、菜单树构建）
 */
public interface SysAdminInfoService {

    AdminController.AdminInfoVO getAdminInfo(Long adminId);

    List<AdminController.MenuTreeVO> getMenuTree(Long adminId);
}
