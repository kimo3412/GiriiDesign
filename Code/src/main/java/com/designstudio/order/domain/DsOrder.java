package com.designstudio.order.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.Version;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 订单主表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_order")
public class DsOrder extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long orderId;

    /** 订单编号 */
    private String orderSn;

    /** 客户ID */
    private Long userId;

    /** 品类ID */
    private Long categoryId;

    /** 指派的设计师ID */
    private Long designerId;

    /** 当前工作流节点 */
    private Long currentStepId;

    /** 0=待支付,1=生产中,2=待发货,3=待收货,4=已完成,5=已取消,6=待付尾款 */
    private Integer status;

    /** 定制参数快照(JSON) */
    private String customDataSnapshot;

    /** 总金额 */
    private BigDecimal totalAmount;

    /** 预付款 */
    private BigDecimal prepayAmount;

    /** 已支付金额 */
    private BigDecimal paidAmount;

    /** 预计交付日期 */
    private LocalDate expectedDate;

    /** 收货地址快照(JSON) */
    private String addressSnapshot;

    /** 备注 */
    private String remark;

    /** 是否阻塞 */
    private Integer isBlocked;

    /** 阻塞原因 */
    private String blockReason;

    /** 版本号(乐观锁) */
    @Version
    private Integer version;

    /** 完成时间 */
    private LocalDateTime finishTime;
}
