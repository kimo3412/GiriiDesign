package com.designstudio.supply.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
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

    /** 物料名称（非持久化，查询时填充） */
    @TableField(exist = false)
    private String materialName;

    /** 物料SKU（非持久化） */
    @TableField(exist = false)
    private String materialSku;

    /** 物料单价（非持久化） */
    @TableField(exist = false)
    private BigDecimal unitPrice;
}
