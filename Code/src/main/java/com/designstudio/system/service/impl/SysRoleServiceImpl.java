package com.designstudio.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.system.controller.SysRoleController;
import com.designstudio.system.domain.SysRole;
import com.designstudio.system.domain.SysRoleMenu;
import com.designstudio.system.mapper.SysRoleMapper;
import com.designstudio.system.mapper.SysRoleMenuMapper;
import com.designstudio.system.service.ISysRoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 角色管理 Service 实现
 */
@Service
@RequiredArgsConstructor
public class SysRoleServiceImpl implements ISysRoleService {

    private final SysRoleMapper roleMapper;
    private final SysRoleMenuMapper roleMenuMapper;

    @Override
    public List<SysRole> listRoles() {
        return roleMapper.selectList(new LambdaQueryWrapper<SysRole>().orderByDesc(SysRole::getCreateTime));
    }

    @Override
    public SysRoleController.RoleDetailVO getRoleDetail(Long id) {
        SysRole role = roleMapper.selectById(id);
        List<SysRoleMenu> roleMenus = roleMenuMapper.selectList(
                new LambdaQueryWrapper<SysRoleMenu>().eq(SysRoleMenu::getRoleId, id));
        List<Long> menuIds = roleMenus.stream().map(SysRoleMenu::getMenuId).collect(Collectors.toList());

        SysRoleController.RoleDetailVO vo = new SysRoleController.RoleDetailVO();
        vo.setRole(role);
        vo.setMenuIds(menuIds);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addRole(SysRoleController.RoleSaveDTO dto) {
        SysRole exist = roleMapper.selectOne(new LambdaQueryWrapper<SysRole>().eq(SysRole::getRoleKey, dto.getRoleKey()));
        if (exist != null) throw new RuntimeException("角色标识已被占用");

        SysRole role = new SysRole();
        role.setRoleName(dto.getRoleName());
        role.setRoleKey(dto.getRoleKey());
        role.setRemark(dto.getRemark());
        roleMapper.insert(role);

        insertRoleMenus(role.getRoleId(), dto.getMenuIds());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateRole(Long id, SysRoleController.RoleSaveDTO dto) {
        SysRole role = roleMapper.selectById(id);
        if (role == null) throw new RuntimeException("角色不存在");

        if (!role.getRoleKey().equals(dto.getRoleKey())) {
            SysRole exist = roleMapper.selectOne(new LambdaQueryWrapper<SysRole>().eq(SysRole::getRoleKey, dto.getRoleKey()));
            if (exist != null) throw new RuntimeException("角色标识已被占用");
        }

        role.setRoleName(dto.getRoleName());
        role.setRoleKey(dto.getRoleKey());
        role.setRemark(dto.getRemark());
        roleMapper.updateById(role);

        roleMenuMapper.delete(new LambdaQueryWrapper<SysRoleMenu>().eq(SysRoleMenu::getRoleId, id));
        insertRoleMenus(id, dto.getMenuIds());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteRole(Long id) {
        if (id == 1L || id == 2L) throw new RuntimeException("内置角色不可删除");
        roleMapper.deleteById(id);
        roleMenuMapper.delete(new LambdaQueryWrapper<SysRoleMenu>().eq(SysRoleMenu::getRoleId, id));
    }

    private void insertRoleMenus(Long roleId, List<Long> menuIds) {
        if (menuIds == null || menuIds.isEmpty()) return;
        for (Long menuId : menuIds) {
            roleMenuMapper.insert(new SysRoleMenu(roleId, menuId));
        }
    }
}
