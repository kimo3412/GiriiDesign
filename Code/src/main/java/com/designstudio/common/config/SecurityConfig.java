package com.designstudio.common.config;

import com.designstudio.common.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Spring Security 安全配置
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                // 关闭 CSRF（前后端分离项目不需要）
                .csrf(AbstractHttpConfigurer::disable)
                // 无状态 Session
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // 请求授权规则
                .authorizeHttpRequests(auth -> auth
                        // 公开接口（登录、注册、API 文档等）
                        .requestMatchers(
                                "/api/v1/auth/**",
                                "/api/v1/app/auth/**",
                                "/api/v1/app/public/**",
                                "/api/v1/portfolios",
                                "/api/v1/portfolios/**",
                                "/api/v1/categories")
                        .permitAll()
                        // Swagger / SpringDoc
                        .requestMatchers(
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/api-docs/**",
                                "/v3/api-docs/**")
                        .permitAll()
                        // 静态资源
                        .requestMatchers("/uploads/**").permitAll()
                        // WebSocket
                        .requestMatchers("/ws/**").permitAll()
                        // 预检请求
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        // 后台管理接口
                        .requestMatchers("/api/v1/admin/**").hasAnyRole("ADMIN", "DESIGNER")
                        // 其余接口需认证
                        .anyRequest().authenticated())
                // 在 UsernamePasswordAuthenticationFilter 前添加 JWT 过滤器
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
