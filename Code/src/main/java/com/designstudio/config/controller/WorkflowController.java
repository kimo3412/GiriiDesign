package com.designstudio.config.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.config.domain.DsWorkflow;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.config.mapper.DsWorkflowMapper;
import com.designstudio.config.mapper.DsWorkflowStepMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
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

    private final DsWorkflowMapper workflowMapper;
    private final DsWorkflowStepMapper stepMapper;

    @GetMapping
    @Operation(summary = "获取品类的工作流（含节点）")
    public R<WorkflowVO> get(@PathVariable Long categoryId) {
        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>()
                        .eq(DsWorkflow::getCategoryId, categoryId));
        if (workflow == null) {
            return R.ok(null);
        }
        List<DsWorkflowStep> steps = stepMapper.selectList(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId())
                        .orderByAsc(DsWorkflowStep::getStepOrder));
        WorkflowVO vo = new WorkflowVO();
        vo.setWorkflow(workflow);
        vo.setSteps(steps);
        return R.ok(vo);
    }

    @PostMapping
    @Operation(summary = "保存工作流（含节点，全量覆盖）")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> save(@PathVariable Long categoryId, @RequestBody WorkflowSaveDTO dto) {
        // 查找或创建工作流
        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>()
                        .eq(DsWorkflow::getCategoryId, categoryId));
        if (workflow == null) {
            workflow = new DsWorkflow();
            workflow.setCategoryId(categoryId);
            workflow.setWorkflowName(dto.getWorkflowName());
            workflowMapper.insert(workflow);
        } else {
            workflow.setWorkflowName(dto.getWorkflowName());
            workflowMapper.updateById(workflow);
        }

        // 删除旧节点
        stepMapper.delete(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId()));

        // 重新插入
        List<DsWorkflowStep> steps = dto.getSteps();
        if (steps != null) {
            for (int i = 0; i < steps.size(); i++) {
                DsWorkflowStep step = steps.get(i);
                step.setStepId(null);
                step.setWorkflowId(workflow.getWorkflowId());
                step.setStepOrder(i + 1);
                step.setIsStartStep(i == 0 ? 1 : 0);
                step.setIsEndStep(i == steps.size() - 1 ? 1 : 0);
                stepMapper.insert(step);
            }
        }
        return R.ok();
    }

    /** 返回给前端的 VO */
    @Data
    public static class WorkflowVO {
        private DsWorkflow workflow;
        private List<DsWorkflowStep> steps;
    }

    /** 前端提交的 DTO */
    @Data
    public static class WorkflowSaveDTO {
        private String workflowName;
        private List<DsWorkflowStep> steps;
    }
}
