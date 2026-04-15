package com.designstudio.common.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 静态资源映射：/uploads/** -> 本地文件目录
 */
@Configuration
public class StaticResourceConfig implements WebMvcConfigurer {

    @Value("${upload.path:/data/uploads/}")
    private String uploadPath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String absolutePath = uploadPath;
        try {
            Path path = Paths.get(uploadPath);
            if (!path.isAbsolute()) {
                // 相对路径则拼接为绝对路径
                absolutePath = path.toAbsolutePath().normalize().toString();
            }
            // 确保目录存在
            Files.createDirectories(Paths.get(absolutePath));
        } catch (Exception e) {
            // 目录创建失败时使用原路径，容器环境可能已有挂载
        }

        String finalPath = absolutePath;
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + finalPath);
    }
}
