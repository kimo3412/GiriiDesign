package com.designstudio.system.controller;

import com.designstudio.common.exception.BusinessException;
import com.designstudio.common.result.ErrorCode;
import com.designstudio.common.result.R;
import com.designstudio.common.security.JwtUtils;
import com.designstudio.system.controller.dto.LoginDTO;
import com.designstudio.system.controller.dto.LoginVO;
import com.designstudio.system.domain.SysAdmin;
import com.designstudio.system.service.ISysAdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.TimeUnit;

/**
 * 认证接口 - 后台登录/登出
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "认证管理", description = "登录/登出接口")
public class AuthController {

    private final ISysAdminService adminService;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final StringRedisTemplate redisTemplate;

    /**
     * 后台登录
     */
    @PostMapping("/login")
    @Operation(summary = "后台登录", description = "使用用户名和密码登录，返回 JWT Token")
    public R<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        // 1. 根据用户名查找用户
        SysAdmin admin = adminService.getByUsername(dto.getUsername());
        if (admin == null) {
            throw new BusinessException(ErrorCode.USERNAME_PASSWORD_ERROR);
        }

        // 2. 校验账号状态
        if (admin.getStatus() != null && admin.getStatus() == 1) {
            throw new BusinessException(ErrorCode.ACCOUNT_DISABLED);
        }

        // 3. 校验密码
        if (!passwordEncoder.matches(dto.getPassword(), admin.getPassword())) {
            throw new BusinessException(ErrorCode.USERNAME_PASSWORD_ERROR);
        }

        // 4. 生成 JWT Token（TODO: 根据角色表查出实际角色）
        String userType = "admin";
        String token = jwtUtils.generateToken(admin.getAdminId(), userType);

        // 5. 构建返回值
        LoginVO vo = LoginVO.builder()
                .token(token)
                .adminId(admin.getAdminId())
                .username(admin.getUsername())
                .nickname(admin.getNickname())
                .avatar(admin.getAvatar())
                .build();

        return R.ok(vo);
    }

    /**
     * 登出 - 将 Token 加入黑名单
     */
    @PostMapping("/logout")
    @Operation(summary = "登出")
    public R<Void> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            // Token 加入 Redis 黑名单，过期时间与 JWT 一致
            redisTemplate.opsForValue().set("token:blacklist:" + token, "1", 7, TimeUnit.DAYS);
        }
        return R.ok();
    }
}
