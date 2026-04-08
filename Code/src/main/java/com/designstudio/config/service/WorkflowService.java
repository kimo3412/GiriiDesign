package com.designstudio.config.service;

import com.designstudio.config.controller.WorkflowController;
import com.designstudio.config.controller.WorkflowController.WorkflowVO;
import com.designstudio.config.controller.WorkflowController.WorkflowSaveDTO;

/**
 * 工作流业务 Service
 */
public interface WorkflowService {

    WorkflowVO getWorkflow(Long categoryId);

    void saveWorkflow(Long categoryId, WorkflowSaveDTO dto);
}
