package com.designstudio.common.controller;

import com.designstudio.common.exception.BusinessException;
import com.designstudio.common.result.ErrorCode;
import com.designstudio.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Set;
import java.util.UUID;

/**
 * 鏂囦欢涓婁紶鎺ュ彛
 * <p>
 * 涓婁紶鍒版湰鍦扮鐩橈紝閫氳繃 Nginx 闈欐€佷唬鐞嗘彁渚涗笅杞?
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/oss")
@Tag(name = "鏂囦欢涓婁紶", description = "鍥剧墖/鏂囦欢涓婁紶鎺ュ彛")
public class OssController {

    @Value("${upload.path}")
    private String uploadPath;

    @Value("${upload.url-prefix}")
    private String urlPrefix;

    /** 鍏佽鐨勬枃浠剁被鍨?*/
    private static final Set<String> ALLOWED_TYPES = Set.of(
            "image/jpeg", "image/png", "image/webp", "image/gif");

    /** 鏈€澶ф枃浠跺ぇ灏忥細5MB */
    private static final long MAX_SIZE = 5 * 1024 * 1024;

    @PostMapping("/upload")
    @Operation(summary = "涓婁紶鍥剧墖", description = "涓婁紶鍥剧墖鍒版湰鍦帮紝杩斿洖璁块棶璺緞")
    public R<String> upload(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("璇烽€夋嫨瑕佷笂浼犵殑鏂囦欢", ErrorCode.PARAM_ERROR.getCode());
        }

        // 鏍￠獙鏂囦欢澶у皬
        if (file.getSize() > MAX_SIZE) {
            throw new BusinessException("鏂囦欢澶у皬涓嶈兘瓒呰繃5MB", ErrorCode.PARAM_ERROR.getCode());
        }

        // 鏍￠獙鏂囦欢绫诲瀷
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_TYPES.contains(contentType)) {
            throw new BusinessException("涓嶆敮鎸佺殑鏂囦欢绫诲瀷", ErrorCode.PARAM_ERROR.getCode());
        }

        try {
            // 鐢熸垚鍞竴鏂囦欢鍚?
            String originalFilename = file.getOriginalFilename();
            String ext = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                ext = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String fileName = UUID.randomUUID().toString().replace("-", "") + ext;

            // 纭繚涓婁紶鐩綍瀛樺湪
            Path dirPath = Paths.get(uploadPath);
            if (!Files.exists(dirPath)) {
                Files.createDirectories(dirPath);
            }

            // 鍐欏叆鏂囦欢
            Path filePath = dirPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath);

            log.info("鏂囦欢涓婁紶鎴愬姛: {}", filePath);

            // 杩斿洖璁块棶璺緞锛圢ginx 浠ｇ悊姝よ矾寰勶級
            return R.ok(urlPrefix + fileName);

        } catch (IOException e) {
            log.error("鏂囦欢涓婁紶澶辫触", e);
            throw new BusinessException("鏂囦欢涓婁紶澶辫触", ErrorCode.SYSTEM_ERROR.getCode());
        }
    }

    @GetMapping("/files/**")
    @Operation(summary = "璁块棶涓婁紶鏂囦欢", description = "閫氳繃 API 璺緞璁块棶涓婁紶鐨勬枃浠讹紝閬垮厤璺ㄥ煙闂")
    public ResponseEntity<Resource> getFile(HttpServletRequest request) {
        String requestUri = request.getRequestURI();
        String filePath = requestUri.substring(requestUri.indexOf("/oss/files") + "/oss/files".length());

        // 瀹夊叏妫€鏌ワ細闃叉璺緞閬嶅巻
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
                contentType = "application/octet-stream";
            }

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CACHE_CONTROL, "max-age=86400")
                    .body(resource);
        } catch (IOException e) {
            log.error("鏂囦欢璇诲彇澶辫触: {}", filePath, e);
            return ResponseEntity.notFound().build();
        }
    }
}

