package com.designstudio.supply.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * BOM模板表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_bom_template")
public class DsBomTemplate extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long templateId;

    /** 模板名称 */
    private String name;

    /** 关联品类 */
    private Long categoryId;

    /** 备注 */
    private String remark;
}
