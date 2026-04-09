package com.designstudio.customer.service.impl;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.security.JwtUtils;
import com.designstudio.customer.controller.AppAuthController;
import com.designstudio.customer.domain.DsUser;
import com.designstudio.customer.mapper.DsUserMapper;
import com.designstudio.customer.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * C端认证业务 Service 实现
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final DsUserMapper userMapper;
    private final JwtUtils jwtUtils;

    @Value("${wechat.miniapp.appid}")
    private String appid;

    @Value("${wechat.miniapp.secret}")
    private String secret;

    @Override
    public AppAuthController.LoginVO wxLogin(String code) {
        if (StrUtil.isBlank(code)) {
            throw new RuntimeException("缺少 wx.login 的 code");
        }

        String url = "https://api.weixin.qq.com/sns/jscode2session?appid=" + appid
                   + "&secret=" + secret
                   + "&js_code=" + code
                   + "&grant_type=authorization_code";

        try {
            String response = HttpUtil.get(url);
            JSONObject json = JSONUtil.parseObj(response);

            String openid = json.getStr("openid");
            if (StrUtil.isBlank(openid)) {
                log.error("微信登录失败: {}", response);
                throw new RuntimeException("微信授权失败: " + json.getStr("errmsg"));
            }

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
                if (StrUtil.isBlank(user.getNickname()) || StrUtil.isBlank(user.getPhone())) {
                    isNew = true;
                }
                user.setLastLoginTime(LocalDateTime.now());
                userMapper.updateById(user);
            }

            if (user.getStatus() == 0) {
                throw new RuntimeException("账号已被禁用");
            }

            return buildLoginVO(user, isNew);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            log.error("调用微信接口出错", e);
            throw new RuntimeException("系统异常：无法连接微信服务器");
        }
    }

    @Override
    public AppAuthController.LoginVO mockLogin(String username, String password) {
        if (StrUtil.isBlank(username)) {
            throw new RuntimeException("请输入用户名");
        }

        DsUser user = userMapper.selectOne(new LambdaQueryWrapper<DsUser>()
                .eq(DsUser::getPhone, username));
        if (user == null) {
            user = userMapper.selectOne(new LambdaQueryWrapper<DsUser>()
                    .eq(DsUser::getNickname, username));
        }
        if (user == null) {
            throw new RuntimeException("用户不存在，请使用已注册的手机号或昵称登录");
        }

        if (user.getStatus() == 0) {
            throw new RuntimeException("账号已被禁用");
        }

        user.setLastLoginTime(LocalDateTime.now());
        userMapper.updateById(user);

        boolean isNew = StrUtil.isBlank(user.getNickname()) || StrUtil.isBlank(user.getPhone());
        return buildLoginVO(user, isNew);
    }

    @Override
    public DsUser getUserInfo(Long userId) {
        return userMapper.selectById(userId);
    }

    @Override
    public void updateUserInfo(Long userId, DsUser dto) {
        DsUser user = new DsUser();
        user.setUserId(userId);
        if (dto.getNickname() != null) user.setNickname(dto.getNickname());
        if (dto.getAvatarUrl() != null) user.setAvatarUrl(dto.getAvatarUrl());
        if (dto.getPhone() != null) user.setPhone(dto.getPhone());
        userMapper.updateById(user);
    }

    private AppAuthController.LoginVO buildLoginVO(DsUser user, boolean isNew) {
        String token = jwtUtils.generateToken(user.getUserId(), "client",
                user.getPhone() != null ? user.getPhone() : "wx",
                user.getNickname() != null ? user.getNickname() : "新用户");

        AppAuthController.LoginVO vo = new AppAuthController.LoginVO();
        vo.setToken(token);
        vo.setUserId(user.getUserId());
        vo.setNickname(user.getNickname());
        vo.setAvatarUrl(user.getAvatarUrl());
        vo.setPhone(user.getPhone());
        vo.setIsNewUser(isNew);
        return vo;
    }
}
