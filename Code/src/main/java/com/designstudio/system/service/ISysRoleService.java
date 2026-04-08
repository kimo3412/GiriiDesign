package com.designstudio.system.service;

import com.designstudio.system.controller.SysRoleController;
import com.designstudio.system.domain.SysRole;

import java.util.List;

/**
 * 角色管理 Service 接口
 */
public interface ISysRoleService {

    List<SysRole> listRoles();

    SysRoleController.RoleDetailVO getRoleDetail(Long id);

    void addRole(SysRoleController.RoleSaveDTO dto);

    void updateRole(Long id, SysRoleController.RoleSaveDTO dto);

    void deleteRole(Long id);
}
