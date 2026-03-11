package com.designstudio.common.controller;

import com.designstudio.common.exception.BusinessException;
import com.designstudio.common.result.ErrorCode;
import com.designstudio.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Set;
import java.util.UUID;

/**
 * 文件上传接口
 * <p>
 * 上传到本地磁盘，通过 Nginx 静态代理提供下载
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/oss")
@Tag(name = "文件上传", description = "图片/文件上传接口")
public class OssController {

    @Value("${upload.path}")
    private String uploadPath;

    @Value("${upload.url-prefix}")
    private String urlPrefix;

    /** 允许的文件类型 */
    private static final Set<String> ALLOWED_TYPES = Set.of(
            "image/jpeg", "image/png", "image/webp", "image/gif");

    /** 最大文件大小：2MB */
    private static final long MAX_SIZE = 2 * 1024 * 1024;

    @PostMapping("/upload")
    @Operation(summary = "上传图片", description = "上传图片到本地，返回访问路径")
    public R<String> upload(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("请选择要上传的文件", ErrorCode.PARAM_ERROR.getCode());
        }

        // 校验文件大小
        if (file.getSize() > MAX_SIZE) {
            throw new BusinessException("文件大小不能超过2MB", ErrorCode.PARAM_ERROR.getCode());
        }

        // 校验文件类型
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_TYPES.contains(contentType)) {
            throw new BusinessException("不支持的文件类型", ErrorCode.PARAM_ERROR.getCode());
        }

        try {
            // 生成唯一文件名
            String originalFilename = file.getOriginalFilename();
            String ext = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                ext = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String fileName = UUID.randomUUID().toString().replace("-", "") + ext;

            // 确保上传目录存在
            Path dirPath = Paths.get(uploadPath);
            if (!Files.exists(dirPath)) {
                Files.createDirectories(dirPath);
            }

            // 写入文件
            Path filePath = dirPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath);

            log.info("文件上传成功: {}", filePath);

            // 返回访问路径（Nginx 代理此路径）
            return R.ok(urlPrefix + fileName);

        } catch (IOException e) {
            log.error("文件上传失败", e);
            throw new BusinessException("文件上传失败", ErrorCode.SYSTEM_ERROR.getCode());
        }
    }
}
