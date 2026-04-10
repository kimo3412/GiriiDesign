package com.designstudio.supply.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 订单BOM明细（按订单的物料清单）
 */
@Data
@TableName("ds_bom_item")
public class DsBomItem implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long bomItemId;

    /** 所属订单 */
    private Long orderId;

    /** 物料ID */
    private Long materialId;

    /** 用量 */
    private BigDecimal quantity;

    /** 物料快照（名称、单价等，JSON） */
    private String materialSnapshot;

    /** 是否已扣库 */
    private Integer isAllocated;

    /** 逻辑删除 */
    private Integer delFlag;
}
