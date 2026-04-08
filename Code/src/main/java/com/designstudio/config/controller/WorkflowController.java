package com.designstudio.config.controller;

import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.config.domain.DsWorkflow;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.config.service.WorkflowService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 工作流管理
 */
@RestController
@RequestMapping("/api/v1/admin/categories/{categoryId}/workflow")
@RequiredArgsConstructor
@Tag(name = "工作流管理")
public class WorkflowController {

    private final WorkflowService workflowService;

    @GetMapping
    @Operation(summary = "获取品类的工作流（含节点）")
    public R<WorkflowVO> get(@PathVariable Long categoryId) {
        return R.ok(workflowService.getWorkflow(categoryId));
    }

    @PostMapping
    @Operation(summary = "保存工作流（含节点，全量覆盖）")
    @OperLog("保存工作流")
    public R<Void> save(@PathVariable Long categoryId, @RequestBody WorkflowSaveDTO dto) {
        workflowService.saveWorkflow(categoryId, dto);
        return R.ok();
    }

    @Data
    public static class WorkflowVO {
        private DsWorkflow workflow;
        private List<DsWorkflowStep> steps;
    }

    @Data
    public static class WorkflowSaveDTO {
        private String workflowName;
        private List<DsWorkflowStep> steps;
    }
}
