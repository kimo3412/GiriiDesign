package com.designstudio.common.security;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.io.Serializable;

/**
 * 当前登录用户信息
 * <p>
 * 存储在 SecurityContext 中，通过 LoginHelper 获取
 */
@Data
@Builder
@AllArgsConstructor
public class LoginUser implements Serializable {

    /** 用户ID（后台用户为 admin_id，小程序用户为 user_id） */
    private Long userId;

    /** 用户类型：admin / designer / client */
    private String userType;

    /** 登录账号 */
    private String username;

    /** 昵称 */
    private String nickname;

    // ===== 便捷方法（兼容 AdminController 调用） =====

    /** 返回 adminId（即 userId） */
    public Long getAdminId() {
        return userId;
    }

    public boolean isAdmin() {
        return "admin".equalsIgnoreCase(userType);
    }

    public boolean isDesigner() {
        return "designer".equalsIgnoreCase(userType);
    }

    public boolean isClient() {
        return "client".equalsIgnoreCase(userType);
    }
}
