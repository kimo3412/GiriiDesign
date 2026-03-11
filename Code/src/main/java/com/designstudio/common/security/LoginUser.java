package com.designstudio.common.security;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;

/**
 * 当前登录用户信息
 * <p>
 * 存储在 SecurityContext 中，通过 LoginHelper 获取
 */
@Data
@AllArgsConstructor
public class LoginUser implements Serializable {

    /** 用户ID（后台用户为 admin_id，小程序用户为 user_id） */
    private Long userId;

    /** 用户类型：admin / designer / client */
    private String userType;

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
