package com.designstudio.config.controller;

import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.common.service.AiCustomerService;
import com.designstudio.config.domain.DsAiConfig;
import com.designstudio.config.service.AiConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * AI config controller.
 */
@RestController
@RequestMapping("/api/v1/admin/ai-config")
@RequiredArgsConstructor
@Tag(name = "AI配置管理")
public class AiConfigController {

    private final AiConfigService aiConfigService;
    private final AiCustomerService aiCustomerService;

    @GetMapping
    @Operation(summary = "获取AI配置")
    public R<DsAiConfig> getConfig() {
        return R.ok(aiConfigService.getConfig());
    }

    @PutMapping
    @Operation(summary = "保存AI配置")
    @OperLog("保存AI配置")
    public R<DsAiConfig> saveConfig(@RequestBody DsAiConfig dto) {
        return R.ok(aiConfigService.saveConfig(dto));
    }

    @PostMapping("/test")
    @Operation(summary = "测试AI回复")
    public R<TestResponseVO> test(@RequestBody TestRequestDTO dto) {
        String reply = aiCustomerService.getResponse(
                null,
                List.of(new AiCustomerService.Message("user", dto.getMessage()))
        );
        TestResponseVO vo = new TestResponseVO();
        vo.setEnabled(aiCustomerService.isEnabled());
        vo.setReply(reply);
        return R.ok(vo);
    }

    @Data
    public static class TestRequestDTO {
        private String message;
    }

    @Data
    public static class TestResponseVO {
        private Boolean enabled;
        private String reply;
    }
}
