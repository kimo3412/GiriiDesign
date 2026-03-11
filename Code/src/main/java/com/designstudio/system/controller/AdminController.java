package com.designstudio.system.controller;

import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.common.security.LoginUser;
import com.designstudio.system.domain.SysMenu;
import com.designstudio.system.mapper.SysMenuMapper;
import com.designstudio.system.mapper.SysRoleMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 后台管理员相关接口
 */
@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@Tag(name = "管理员信息")
public class AdminController {

    private final SysRoleMapper roleMapper;
    private final SysMenuMapper menuMapper;

    @GetMapping("/info")
    @Operation(summary = "获取当前登录用户信息（含角色和权限标识）")
    public R<AdminInfoVO> info() {
        LoginUser loginUser = LoginHelper.getLoginUser();

        AdminInfoVO vo = new AdminInfoVO();
        vo.setAdminId(loginUser.getAdminId());
        vo.setUsername(loginUser.getUsername());
        vo.setNickname(loginUser.getNickname());

        // 查询角色标识
        List<String> roleKeys = roleMapper.selectRoleKeysByAdminId(loginUser.getAdminId());
        vo.setRoles(roleKeys);

        // 查询权限标识
        List<String> perms;
        if (roleKeys.contains("admin")) {
            perms = List.of("*:*:*"); // 管理员拥有全部权限
        } else {
            perms = menuMapper.selectPermsByAdminId(loginUser.getAdminId());
        }
        vo.setPermissions(perms);

        return R.ok(vo);
    }

    @GetMapping("/menus")
    @Operation(summary = "获取当前用户的菜单树（用于前端动态路由）")
    public R<List<MenuTreeVO>> menus() {
        LoginUser loginUser = LoginHelper.getLoginUser();
        List<String> roleKeys = roleMapper.selectRoleKeysByAdminId(loginUser.getAdminId());

        List<SysMenu> flatMenus;
        if (roleKeys.contains("admin")) {
            // 管理员看到所有菜单
            flatMenus = menuMapper.selectList(null);
        } else {
            flatMenus = menuMapper.selectMenusByAdminId(loginUser.getAdminId());
        }

        // 构建菜单树
        List<MenuTreeVO> tree = buildTree(flatMenus, 0L);
        return R.ok(tree);
    }

    /** 递归构建菜单树 */
    private List<MenuTreeVO> buildTree(List<SysMenu> allMenus, Long parentId) {
        return allMenus.stream()
                .filter(m -> Objects.equals(m.getParentId(), parentId))
                .map(m -> {
                    MenuTreeVO node = new MenuTreeVO();
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

    // ========== VO ==========

    @Data
    public static class AdminInfoVO {
        private Long adminId;
        private String username;
        private String nickname;
        private List<String> roles;
        private List<String> permissions;
    }

    @Data
    public static class MenuTreeVO {
        private Long menuId;
        private String menuName;
        private String menuType;
        private String path;
        private String component;
        private String perms;
        private String icon;
        private Integer sortOrder;
        private Integer visible;
        private List<MenuTreeVO> children;
    }
}
