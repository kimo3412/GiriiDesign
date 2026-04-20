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
 * Spring Security configuration.
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
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/api/v1/auth/**",
                                "/api/v1/app/auth/**",
                                "/api/v1/app/public/**",
                                "/api/v1/portfolios",
                                "/api/v1/portfolios/**",
                                "/api/v1/categories"
                        ).permitAll()
                        .requestMatchers(
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/api-docs/**",
                                "/v3/api-docs/**"
                        ).permitAll()
                        .requestMatchers("/uploads/**").permitAll()
                        .requestMatchers("/ws/**").permitAll()
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers(
                                "/api/v1/admin/users/**",
                                "/api/v1/admin/roles/**",
                                "/api/v1/admin/menu-list/**",
                                "/api/v1/admin/dict/**",
                                "/api/v1/admin/logs/**",
                                "/api/v1/admin/ai-config/**"
                        ).hasRole("ADMIN")
                        .requestMatchers("/api/v1/admin/customers/**").hasAnyRole("ADMIN", "CUSTOMER_SERVICE")
                        .requestMatchers("/api/v1/admin/chat/**").hasAnyRole("ADMIN", "DESIGNER", "CUSTOMER_SERVICE")
                        .requestMatchers("/api/v1/admin/statistics/**").hasAnyRole("ADMIN", "FINANCE")
                        .requestMatchers(HttpMethod.GET, "/api/v1/admin/orders/**").hasAnyRole("ADMIN", "DESIGNER", "FINANCE")
                        .requestMatchers(
                                "/api/v1/admin/materials/**",
                                "/api/v1/admin/bom-templates/**"
                        ).hasAnyRole("ADMIN", "DESIGNER", "STOREKEEPER", "PURCHASER")
                        .requestMatchers("/api/v1/admin/workbench/**").hasAnyRole("ADMIN", "DESIGNER")
                        .requestMatchers("/api/v1/admin/orders/**").hasAnyRole("ADMIN", "DESIGNER")
                        .requestMatchers("/api/v1/admin/requests/**").hasAnyRole("ADMIN", "DESIGNER", "CUSTOMER_SERVICE")
                        .requestMatchers(
                                "/api/v1/admin/portfolios/**",
                                "/api/v1/admin/categories/**",
                                "/api/v1/admin/banners/**"
                        ).hasAnyRole("ADMIN", "DESIGNER")
                        .requestMatchers("/api/v1/admin/**").hasAnyRole(
                                "ADMIN",
                                "DESIGNER",
                                "STOREKEEPER",
                                "PURCHASER",
                                "FINANCE",
                                "CUSTOMER_SERVICE"
                        )
                        .anyRequest().authenticated())
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
