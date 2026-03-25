package com.designstudio.customer.controller;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
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
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * 小程序端 - 认证与用户接口
 */
@RestController
@RequestMapping("/api/v1/app/auth")
@RequiredArgsConstructor
@Tag(name = "C端-用户认证")
@Slf4j
public class AppAuthController {

    private final DsUserMapper userMapper;
    private final JwtUtils jwtUtils;

    @Value("${wechat.miniapp.appid}")
    private String appid;

    @Value("${wechat.miniapp.secret}")
    private String secret;

    @PostMapping("/wx-login")
    @Operation(summary = "真实微信登录（通过 code 换取 openid）")
    public R<LoginVO> realWxLogin(@RequestBody LoginDTO dto) {
        if (StrUtil.isBlank(dto.getCode())) {
            return R.fail("缺少 wx.login 的 code");
        }

        String url = "https://api.weixin.qq.com/sns/jscode2session?appid=" + appid 
                   + "&secret=" + secret 
                   + "&js_code=" + dto.getCode() 
                   + "&grant_type=authorization_code";

        try {
            String response = HttpUtil.get(url);
            JSONObject json = JSONUtil.parseObj(response);
            
            String openid = json.getStr("openid");
            if (StrUtil.isBlank(openid)) {
                log.error("微信登录失败: {}", response);
                return R.fail("微信授权失败: " + json.getStr("errmsg"));
            }

            // 查找或创建用户
            boolean isNew = false;
            DsUser user = userMapper.selectOne(new LambdaQueryWrapper<DsUser>()
                    .eq(DsUser::getOpenid, openid));

            if (user == null) {
                isNew = true;
                user = new DsUser();
                user.setOpenid(openid);
                user.setStatus(1);
                user.setCreateTime(LocalDateTime.now());
                user.setLastLoginTime(LocalDateTime.now());
                userMapper.insert(user);
            } else {
                // 老用户但资料未完善也算新用户
                if (StrUtil.isBlank(user.getNickname()) || StrUtil.isBlank(user.getPhone())) {
                    isNew = true;
                }
                user.setLastLoginTime(LocalDateTime.now());
                userMapper.updateById(user);
            }

            if (user.getStatus() == 0) {
                return R.fail("账号已被禁用");
            }

            String token = jwtUtils.generateToken(user.getUserId(), "client", user.getPhone() != null ? user.getPhone() : "wx", user.getNickname() != null ? user.getNickname() : "新用户");

            LoginVO vo = new LoginVO();
            vo.setToken(token);
            vo.setUserId(user.getUserId());
            vo.setNickname(user.getNickname());
            vo.setAvatarUrl(user.getAvatarUrl());
            vo.setPhone(user.getPhone());
            vo.setIsNewUser(isNew);
            return R.ok(vo);

        } catch (Exception e) {
            log.error("调用微信接口出错", e);
            return R.fail("系统异常：无法连接微信服务器");
        }
    }

    @PostMapping("/mock-login")
    @Operation(summary = "模拟微信登录（一键生成/登录测试号）")
    public R<LoginVO> mockLogin(@RequestBody LoginDTO dto) {
        String mockOpenid = "wx_test_openid_" + dto.getPhone();

        boolean isNew = false;
        DsUser user = userMapper.selectOne(new LambdaQueryWrapper<DsUser>()
                .eq(DsUser::getOpenid, mockOpenid));

        if (user == null) {
            isNew = true;
            user = new DsUser();
            user.setOpenid(mockOpenid);
            user.setPhone(dto.getPhone());
            user.setStatus(1);
            user.setCreateTime(LocalDateTime.now());
            user.setLastLoginTime(LocalDateTime.now());
            userMapper.insert(user);
        } else {
            if (StrUtil.isBlank(user.getNickname())) {
                isNew = true;
            }
            user.setLastLoginTime(LocalDateTime.now());
            userMapper.updateById(user);
        }

        if (user.getStatus() == 0) {
            return R.fail("账号已被禁用");
        }

        String token = jwtUtils.generateToken(user.getUserId(), "client", user.getPhone(), user.getNickname() != null ? user.getNickname() : "新用户");

        LoginVO vo = new LoginVO();
        vo.setToken(token);
        vo.setUserId(user.getUserId());
        vo.setNickname(user.getNickname());
        vo.setAvatarUrl(user.getAvatarUrl());
        vo.setPhone(user.getPhone());
        vo.setIsNewUser(isNew);
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
    @Operation(summary = "更新用户信息（完善资料）")
    public R<Void> updateInfo(@RequestBody DsUser dto) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        DsUser user = new DsUser();
        user.setUserId(userId);
        if (dto.getNickname() != null) user.setNickname(dto.getNickname());
        if (dto.getAvatarUrl() != null) user.setAvatarUrl(dto.getAvatarUrl());
        if (dto.getPhone() != null) user.setPhone(dto.getPhone());
        userMapper.updateById(user);
        return R.ok();
    }

    // ====== DTO & VO ======

    @Data
    public static class LoginDTO {
        private String phone; // 测试用一键登录输入手机号
        private String code;  // 真实微信登录所需的 jscode
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
