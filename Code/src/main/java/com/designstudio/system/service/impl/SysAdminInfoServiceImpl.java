package com.designstudio.system.service.impl;

import com.designstudio.system.controller.AdminController;
import com.designstudio.system.domain.SysMenu;
import com.designstudio.system.mapper.SysMenuMapper;
import com.designstudio.system.mapper.SysRoleMapper;
import com.designstudio.system.service.SysAdminInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 管理员信息 Service 实现
 */
@Service
@RequiredArgsConstructor
public class SysAdminInfoServiceImpl implements SysAdminInfoService {

    private final SysRoleMapper roleMapper;
    private final SysMenuMapper menuMapper;

    @Override
    public AdminController.AdminInfoVO getAdminInfo(Long adminId) {
        AdminController.AdminInfoVO vo = new AdminController.AdminInfoVO();
        // adminId, username, nickname 由 Controller 从 LoginUser 填充
        // 这里只查角色和权限

        List<String> roleKeys = roleMapper.selectRoleKeysByAdminId(adminId);
        vo.setRoles(roleKeys);

        List<String> perms;
        if (roleKeys.contains("admin")) {
            perms = List.of("*:*:*");
        } else {
            perms = menuMapper.selectPermsByAdminId(adminId);
        }
        vo.setPermissions(perms);
        return vo;
    }

    @Override
    public List<AdminController.MenuTreeVO> getMenuTree(Long adminId) {
        List<String> roleKeys = roleMapper.selectRoleKeysByAdminId(adminId);

        List<SysMenu> flatMenus;
        if (roleKeys.contains("admin")) {
            flatMenus = menuMapper.selectList(null);
        } else {
            flatMenus = menuMapper.selectMenusByAdminId(adminId);
        }

        return buildTree(flatMenus, 0L);
    }

    private List<AdminController.MenuTreeVO> buildTree(List<SysMenu> allMenus, Long parentId) {
        return allMenus.stream()
                .filter(m -> Objects.equals(m.getParentId(), parentId))
                .map(m -> {
                    AdminController.MenuTreeVO node = new AdminController.MenuTreeVO();
                    node.setMenuId(m.getMenuId());
                    node.setMenuName(m.getMenuName());
                    node.setMenuType(m.getMenuType());
                    node.setPath(m.getPath());
                    node.setComponent(m.getComponent());
                    node.setPerms(m.getPerms());
                    node.setIcon(m.getIcon());
                    node.setSortOrder(m.getSortOrder());
                    node.setVisible(m.getVisible());
                    node.setChildren(buildTree(allMenus, m.getMenuId()));
                    return node;
                })
                .sorted((a, b) -> (a.getSortOrder() == null ? 0 : a.getSortOrder())
                        - (b.getSortOrder() == null ? 0 : b.getSortOrder()))
                .collect(Collectors.toList());
    }
}
