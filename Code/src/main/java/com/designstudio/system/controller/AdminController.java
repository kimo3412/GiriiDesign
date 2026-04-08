package com.designstudio.system.controller;

import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.common.security.LoginUser;
import com.designstudio.system.service.SysAdminInfoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 后台管理员相关接口
 */
@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@Tag(name = "管理员信息")
public class AdminController {

    private final SysAdminInfoService adminInfoService;

    @GetMapping("/info")
    @Operation(summary = "获取当前登录用户信息（含角色和权限标识）")
    public R<AdminInfoVO> info() {
        LoginUser loginUser = LoginHelper.getLoginUser();

        AdminInfoVO vo = adminInfoService.getAdminInfo(loginUser.getAdminId());
        vo.setAdminId(loginUser.getAdminId());
        vo.setUsername(loginUser.getUsername());
        vo.setNickname(loginUser.getNickname());
        return R.ok(vo);
    }

    @GetMapping("/menus")
    @Operation(summary = "获取当前用户的菜单树（用于前端动态路由）")
    public R<List<MenuTreeVO>> menus() {
        LoginUser loginUser = LoginHelper.getLoginUser();
        return R.ok(adminInfoService.getMenuTree(loginUser.getAdminId()));
    }

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
