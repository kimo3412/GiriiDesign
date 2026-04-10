package com.designstudio.config.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 工作流节点实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_workflow_step")
public class DsWorkflowStep extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long stepId;

    /** 所属工作流ID */
    private Long workflowId;

    /** 节点名称 */
    private String stepName;

    /** 节点顺序 */
    private Integer stepOrder;

    /** 是否起始节点 */
    private Integer isStartStep;

    /** 是否结束节点 */
    private Integer isEndStep;

    private String nodeDescription;

    private String allowedActions;

    private Integer needImageUpload;

    private Integer visibleToClient;

    private Integer expectedDurationDays;

    private String nodeFormFields;
}
