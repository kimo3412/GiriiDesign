package com.designstudio.supply.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * BOM模板明细表
 */
@Data
@TableName("ds_bom_template_item")
public class DsBomTemplateItem implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long itemId;

    /** 所属模板 */
    private Long templateId;

    /** 物料ID */
    private Long materialId;

    /** 所需数量 */
    private BigDecimal quantity;

    /** 逻辑删除 */
    private Integer delFlag;
}
