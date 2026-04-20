package com.designstudio.system.controller;

import com.designstudio.common.annotation.OperLog;
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Authentication endpoints for admin login/logout.
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

    @PostMapping("/login")
    @Operation(summary = "后台登录", description = "使用用户名和密码登录，返回 JWT Token")
    @OperLog("后台登录")
    public R<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        SysAdmin admin = adminService.getByUsername(dto.getUsername());
        if (admin == null) {
            throw new BusinessException(ErrorCode.USERNAME_PASSWORD_ERROR);
        }

        if (admin.getStatus() != null && admin.getStatus() == 0) {
            throw new BusinessException(ErrorCode.ACCOUNT_DISABLED);
        }

        if (!passwordEncoder.matches(dto.getPassword(), admin.getPassword())) {
            throw new BusinessException(ErrorCode.USERNAME_PASSWORD_ERROR);
        }

        List<String> roleKeys = adminService.getRoleKeysByAdminId(admin.getAdminId());
        String token = jwtUtils.generateToken(
                admin.getAdminId(),
                "admin",
                admin.getUsername(),
                admin.getNickname(),
                roleKeys
        );

        LoginVO vo = LoginVO.builder()
                .token(token)
                .adminId(admin.getAdminId())
                .username(admin.getUsername())
                .nickname(admin.getNickname())
                .avatar(admin.getAvatar())
                .build();

        return R.ok(vo);
    }

    @PostMapping("/logout")
    @Operation(summary = "后台登出")
    @OperLog("后台登出")
    public R<Void> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            redisTemplate.opsForValue().set("token:blacklist:" + token, "1", 7, TimeUnit.DAYS);
        }
        return R.ok();
    }
}
