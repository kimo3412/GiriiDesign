package com.designstudio.customer.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.common.security.JwtUtils;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.customer.domain.DsUser;
import com.designstudio.customer.mapper.DsUserMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * 小程序端 - 认证与用户接口
 */
@RestController
@RequestMapping("/api/v1/app/auth")
@RequiredArgsConstructor
@Tag(name = "C端-用户认证")
public class AppAuthController {

    private final DsUserMapper userMapper;
    private final JwtUtils jwtUtils;

    @PostMapping("/mock-login")
    @Operation(summary = "模拟微信登录（一键生成/登录测试号）")
    public R<LoginVO> mockLogin(@RequestBody LoginDTO dto) {
        String mockOpenid = "wx_test_openid_" + dto.getPhone();

        // 查找或创建用户
        DsUser user = userMapper.selectOne(new LambdaQueryWrapper<DsUser>()
                .eq(DsUser::getOpenid, mockOpenid));

        if (user == null) {
            user = new DsUser();
            user.setOpenid(mockOpenid);
            user.setPhone(dto.getPhone());
            user.setNickname("客户" + dto.getPhone().substring(7));
            user.setStatus(1);
            user.setCreateTime(LocalDateTime.now());
            user.setLastLoginTime(LocalDateTime.now());
            userMapper.insert(user);
        } else {
            user.setLastLoginTime(LocalDateTime.now());
            userMapper.updateById(user);
        }

        if (user.getStatus() == 0) {
            return R.fail("账号已被禁用");
        }

        // 生成 C 端 Token (userType = client)
        String token = jwtUtils.generateToken(user.getUserId(), "client", user.getPhone(), user.getNickname());

        LoginVO vo = new LoginVO();
        vo.setToken(token);
        vo.setUserId(user.getUserId());
        vo.setNickname(user.getNickname());
        vo.setAvatarUrl(user.getAvatarUrl());
        return R.ok(vo);
    }

    @GetMapping("/info")
    @Operation(summary = "获取当前C端用户信息")
    public R<DsUser> info() {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        DsUser user = userMapper.selectById(userId);
        return R.ok(user);
    }

    @PostMapping("/update")
    @Operation(summary = "更新用户信息")
    public R<Void> updateInfo(@RequestBody DsUser dto) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        DsUser user = new DsUser();
        user.setUserId(userId);
        user.setNickname(dto.getNickname());
        user.setAvatarUrl(dto.getAvatarUrl());
        userMapper.updateById(user);
        return R.ok();
    }

    // ====== DTO & VO ======

    @Data
    public static class LoginDTO {
        private String phone; // 测试用一键登录输入手机号
    }

    @Data
    public static class LoginVO {
        private String token;
        private Long userId;
        private String nickname;
        private String avatarUrl;
    }
}
