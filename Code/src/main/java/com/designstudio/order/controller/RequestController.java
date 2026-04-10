package com.designstudio.order.controller;

import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderRequest;
import com.designstudio.order.service.RequestService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * 意向管理 Controller
 */
@RestController
@RequestMapping("/api/v1/admin/requests")
@RequiredArgsConstructor
@Tag(name = "意向管理")
public class RequestController {

    private final RequestService requestService;

    @GetMapping
    @Operation(summary = "获取意向列表")
    public R<List<DsOrderRequest>> list(
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long categoryId) {
        return R.ok(requestService.listRequests(status, categoryId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取意向详情")
    public R<DsOrderRequest> get(@PathVariable Long id) {
        return R.ok(requestService.getRequest(id));
    }

    @PostMapping("/{requestId}/convert")
    @Operation(summary = "意向转正订单")
    @OperLog("意向转订单")
    public R<DsOrder> convert(@PathVariable Long requestId, @RequestBody ConvertDTO dto) {
        try {
            return R.ok(requestService.convert(requestId, dto));
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/{requestId}/close")
    @Operation(summary = "关闭意向")
    @OperLog("关闭意向")
    public R<Void> close(@PathVariable Long requestId, @RequestBody CloseDTO dto) {
        try {
            requestService.close(requestId, dto.getCloseReason());
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @Data
    public static class ConvertDTO {
        private Long designerId;
        private BigDecimal totalAmount;
        private BigDecimal prepayAmount;
        private LocalDate expectedDate;
        private String remark;
        private Long bomTemplateId;
    }

    @Data
    public static class CloseDTO {
        private String closeReason;
    }
}
