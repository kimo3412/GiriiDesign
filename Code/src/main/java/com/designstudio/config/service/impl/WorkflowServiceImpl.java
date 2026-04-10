package com.designstudio.config.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.config.controller.WorkflowController.WorkflowSaveDTO;
import com.designstudio.config.controller.WorkflowController.WorkflowVO;
import com.designstudio.config.domain.DsWorkflow;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.config.mapper.DsWorkflowMapper;
import com.designstudio.config.mapper.DsWorkflowStepMapper;
import com.designstudio.config.service.WorkflowService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 工作流业务 Service 实现
 */
@Service
@RequiredArgsConstructor
public class WorkflowServiceImpl implements WorkflowService {

    private final DsWorkflowMapper workflowMapper;
    private final DsWorkflowStepMapper stepMapper;

    @Override
    public WorkflowVO getWorkflow(Long categoryId) {
        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>()
                        .eq(DsWorkflow::getCategoryId, categoryId));
        if (workflow == null) {
            return null;
        }
        List<DsWorkflowStep> steps = stepMapper.selectList(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId())
                        .orderByAsc(DsWorkflowStep::getStepOrder));
        WorkflowVO vo = new WorkflowVO();
        vo.setWorkflow(workflow);
        vo.setSteps(steps);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveWorkflow(Long categoryId, WorkflowSaveDTO dto) {
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

        stepMapper.delete(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId()));

        List<DsWorkflowStep> steps = dto.getSteps();
        if (steps != null) {
            for (int i = 0; i < steps.size(); i++) {
                DsWorkflowStep step = steps.get(i);
                step.setStepId(null);
                step.setWorkflowId(workflow.getWorkflowId());
                step.setStepOrder(i + 1);
                step.setIsStartStep(i == 0 ? 1 : 0);
                step.setIsEndStep(i == steps.size() - 1 ? 1 : 0);
                if (step.getNeedImageUpload() == null) {
                    step.setNeedImageUpload(0);
                }
                if (step.getVisibleToClient() == null) {
                    step.setVisibleToClient(1);
                }
                if (!StringUtils.hasText(step.getAllowedActions())) {
                    step.setAllowedActions("[\"save\",\"advance\",\"rollback\",\"block\",\"unblock\"]");
                }
                stepMapper.insert(step);
            }
        }
    }
}
