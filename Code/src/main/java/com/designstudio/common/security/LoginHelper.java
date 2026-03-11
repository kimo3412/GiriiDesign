package com.designstudio.common.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * 登录用户助手 - 从 SecurityContext 获取当前登录用户
 */
public class LoginHelper {

    /**
     * 获取当前登录用户
     */
    public static LoginUser getLoginUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof LoginUser loginUser) {
            return loginUser;
        }
        return null;
    }

    /**
     * 获取当前用户ID
     */
    public static Long getUserId() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null ? loginUser.getUserId() : null;
    }

    /**
     * 获取当前用户类型
     */
    public static String getUserType() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null ? loginUser.getUserType() : null;
    }

    /**
     * 是否管理员
     */
    public static boolean isAdmin() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null && loginUser.isAdmin();
    }

    /**
     * 是否设计师
     */
    public static boolean isDesigner() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null && loginUser.isDesigner();
    }

    /**
     * 是否客户
     */
    public static boolean isClient() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null && loginUser.isClient();
    }
}
