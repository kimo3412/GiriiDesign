package com.designstudio.config.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 工作流模板实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_workflow")
public class DsWorkflow extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long workflowId;

    /** 关联品类 */
    private Long categoryId;

    /** 工作流名称 */
    private String workflowName;
}
