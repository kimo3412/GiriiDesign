package com.designstudio.common.controller;

import com.designstudio.common.exception.BusinessException;
import com.designstudio.common.result.ErrorCode;
import com.designstudio.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
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

@Slf4j
@RestController
@RequestMapping("/api/v1/oss")
@Tag(name = "File upload")
public class OssController {

    @Value("${upload.path}")
    private String uploadPath;

    @Value("${upload.url-prefix}")
    private String urlPrefix;

    private static final Set<String> ALLOWED_IMAGE_TYPES = Set.of(
            "image/jpeg", "image/png", "image/webp", "image/gif");

    private static final long IMAGE_MAX_SIZE = 5 * 1024 * 1024;

    @PostMapping("/upload")
    @Operation(summary = "Upload image")
    public R<String> upload(MultipartFile file) {
        validateFile(file);
        if (file.getSize() > IMAGE_MAX_SIZE) {
            throw new BusinessException("文件大小不能超过5MB", ErrorCode.PARAM_ERROR.getCode());
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_IMAGE_TYPES.contains(contentType)) {
            throw new BusinessException("仅支持 jpg/png/webp/gif 图片", ErrorCode.PARAM_ERROR.getCode());
        }
        return R.ok(saveFile(file, "images"));
    }

    @PostMapping("/chat-upload")
    @Operation(summary = "Upload chat attachment")
    public R<String> uploadChatAttachment(MultipartFile file) {
        validateFile(file);
        return R.ok(saveFile(file, "chat"));
    }

    @GetMapping("/files/**")
    @Operation(summary = "Read uploaded file")
    public ResponseEntity<Resource> getFile(HttpServletRequest request) {
        String requestUri = request.getRequestURI();
        String filePath = requestUri.substring(requestUri.indexOf("/oss/files") + "/oss/files".length());
        if (filePath.contains("..")) {
            return ResponseEntity.notFound().build();
        }

        try {
            Path file = Paths.get(uploadPath).resolve(filePath.substring(1)).normalize();
            if (!Files.exists(file) || !Files.isRegularFile(file)) {
                return ResponseEntity.notFound().build();
            }

            Resource resource = new UrlResource(file.toUri());
            String contentType = Files.probeContentType(file);
            if (contentType == null) {
                contentType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
            }

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CACHE_CONTROL, "max-age=86400")
                    .body(resource);
        } catch (IOException e) {
            log.error("Failed to read uploaded file: {}", filePath, e);
            return ResponseEntity.notFound().build();
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("请选择上传文件", ErrorCode.PARAM_ERROR.getCode());
        }
    }

    private String saveFile(MultipartFile file, String folder) {
        try {
            String originalFilename = file.getOriginalFilename();
            String ext = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                ext = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String fileName = UUID.randomUUID().toString().replace("-", "") + ext;

            Path dirPath = Paths.get(uploadPath).resolve(folder).normalize();
            Files.createDirectories(dirPath);

            Path filePath = dirPath.resolve(fileName).normalize();
            Files.copy(file.getInputStream(), filePath);

            String normalizedPrefix = urlPrefix.endsWith("/") ? urlPrefix : urlPrefix + "/";
            String url = normalizedPrefix + folder + "/" + fileName;
            log.info("Uploaded file saved: {}", filePath);
            return url;
        } catch (IOException e) {
            log.error("Failed to upload file", e);
            throw new BusinessException("文件上传失败", ErrorCode.SYSTEM_ERROR.getCode());
        }
    }
}
