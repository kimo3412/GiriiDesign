package com.designstudio.supply.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.Version;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/**
 * 物料表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_material")
public class DsMaterial extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long materialId;

    /** 物料名称 */
    private String name;

    /** 物料编码 */
    private String sku;

    /** 物料分类(面料/辅料/五金) */
    private String category;

    /** 单位 */
    private String unit;

    /** 单价 */
    private BigDecimal unitPrice;

    /** 当前库存 */
    private BigDecimal stock;

    /** 预警阈值 */
    private BigDecimal warningStock;

    /** 图片 */
    private String imageUrl;

    /** 备注 */
    private String remark;

    /** 乐观锁 */
    @Version
    private Integer version;
}
