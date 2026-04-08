package com.designstudio.customer.service;

import com.designstudio.customer.controller.AppAuthController;
import com.designstudio.customer.domain.DsUser;

/**
 * C端认证业务 Service
 */
public interface AuthService {

    AppAuthController.LoginVO wxLogin(String code);

    AppAuthController.LoginVO mockLogin(String username, String password);

    DsUser getUserInfo(Long userId);

    void updateUserInfo(Long userId, DsUser dto);
}
