package com.designstudio.common.security;

import com.designstudio.common.result.ErrorCode;
import com.designstudio.common.result.R;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * JWT authentication filter.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtils jwtUtils;
    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    private static final String TOKEN_PREFIX = "Bearer ";
    private static final String HEADER_NAME = "Authorization";
    private static final String BLACKLIST_PREFIX = "token:blacklist:";

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String token = getTokenFromHeader(request);

        if (StringUtils.hasText(token) && jwtUtils.validateToken(token)) {
            Boolean inBlacklist = redisTemplate.hasKey(BLACKLIST_PREFIX + token);
            if (Boolean.TRUE.equals(inBlacklist)) {
                writeErrorResponse(response, ErrorCode.TOKEN_INVALID);
                return;
            }

            Long userId = jwtUtils.getUserIdFromToken(token);
            String userType = jwtUtils.getUserTypeFromToken(token);
            String username = jwtUtils.getUsernameFromToken(token);
            String nickname = jwtUtils.getNicknameFromToken(token);
            List<String> roleKeys = jwtUtils.getRolesFromToken(token);

            List<SimpleGrantedAuthority> authorities = buildAuthorities(userType, roleKeys);

            LoginUser loginUser = LoginUser.builder()
                    .userId(userId)
                    .userType(userType)
                    .username(username)
                    .nickname(nickname)
                    .roleKeys(roleKeys)
                    .build();

            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(loginUser, null, authorities);
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        filterChain.doFilter(request, response);
    }

    private List<SimpleGrantedAuthority> buildAuthorities(String userType, List<String> roleKeys) {
        if (roleKeys != null && !roleKeys.isEmpty()) {
            return roleKeys.stream()
                    .filter(StringUtils::hasText)
                    .map(role -> new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()))
                    .toList();
        }
        return Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + userType.toUpperCase()));
    }

    private String getTokenFromHeader(HttpServletRequest request) {
        String header = request.getHeader(HEADER_NAME);
        if (StringUtils.hasText(header) && header.startsWith(TOKEN_PREFIX)) {
            return header.substring(TOKEN_PREFIX.length());
        }
        return null;
    }

    private void writeErrorResponse(HttpServletResponse response, ErrorCode errorCode) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(objectMapper.writeValueAsString(R.fail(errorCode)));
    }
}
