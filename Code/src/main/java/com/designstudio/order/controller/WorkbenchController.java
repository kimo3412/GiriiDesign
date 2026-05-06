package com.designstudio.order.controller;

import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/workbench")
@RequiredArgsConstructor
@Tag(name = "节点工作台")
public class WorkbenchController {

    private final OrderService orderService;

    @GetMapping("/categories/{categoryId}")
    @Operation(summary = "获取品类节点工作台数据")
    public R<WorkbenchVO> getWorkbench(@PathVariable Long categoryId,
                                       @RequestParam(required = false) Long stepId) {
        return R.ok(orderService.getWorkbenchData(categoryId, stepId));
    }

    @PostMapping("/orders/{orderId}/action")
    @Operation(summary = "执行工作台动作")
    @OperLog("执行节点工作台动作")
    public R<Void> action(@PathVariable Long orderId, @RequestBody WorkbenchActionDTO dto) {
        try {
            orderService.handleWorkbenchAction(orderId, dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @Data
    public static class WorkbenchVO {
        private Long categoryId;
        private Long selectedStepId;
        private List<DsWorkflowStep> workflowSteps;
        private List<DsOrder> orders;
    }

    @Data
    public static class WorkbenchActionDTO {
        private String action;
        private Long expectedCurrentStepId;
        private String description;
        private String imageUrls;
        private String formData;
        private String blockReason;
        private Long rollbackTargetStepId;
    }
}
