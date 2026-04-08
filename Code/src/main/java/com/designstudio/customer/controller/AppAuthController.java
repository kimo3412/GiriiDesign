package com.designstudio.customer.controller;

import cn.hutool.core.util.StrUtil;
import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.customer.domain.DsUser;
import com.designstudio.customer.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 小程序端 - 认证与用户接口
 */
@RestController
@RequestMapping("/api/v1/app/auth")
@RequiredArgsConstructor
@Tag(name = "C端-用户认证")
public class AppAuthController {

    private final AuthService authService;

    @PostMapping("/wx-login")
    @Operation(summary = "真实微信登录（通过 code 换取 openid）")
    public R<LoginVO> realWxLogin(@RequestBody LoginDTO dto) {
        if (StrUtil.isBlank(dto.getCode())) {
            return R.fail("缺少 wx.login 的 code");
        }
        try {
            return R.ok(authService.wxLogin(dto.getCode()));
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/mock-login")
    @Operation(summary = "账号密码登录（开发调试用）")
    public R<LoginVO> mockLogin(@RequestBody LoginDTO dto) {
        try {
            return R.ok(authService.mockLogin(dto.getUsername(), dto.getPassword()));
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @GetMapping("/info")
    @Operation(summary = "获取当前C端用户信息")
    public R<DsUser> info() {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        return R.ok(authService.getUserInfo(userId));
    }

    @PostMapping("/update")
    @Operation(summary = "更新用户信息（完善资料）")
    public R<Void> updateInfo(@RequestBody DsUser dto) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        authService.updateUserInfo(userId, dto);
        return R.ok();
    }

    @Data
    public static class LoginDTO {
        private String phone;
        private String code;
        private String username;
        private String password;
    }

    @Data
    public static class LoginVO {
        private String token;
        private Long userId;
        private String nickname;
        private String avatarUrl;
        private String phone;
        private Boolean isNewUser;
    }
}
