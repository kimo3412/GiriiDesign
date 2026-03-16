package com.designstudio.order.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 订单意向/需求表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_order_request")
public class DsOrderRequest extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long requestId;

    /** 提交客户 */
    private Long userId;

    /** 定制品类 */
    private Long categoryId;

    /** 客户文字描述 */
    private String description;

    /** 参考图片(JSON数组) */
    private String imageUrls;

    /** 动态表单数据(JSON) */
    private String customData;

    /** 0=待处理,1=已转单,2=已关闭 */
    private Integer status;

    /** 关闭原因 */
    private String closeReason;

    /** 转化后的订单ID */
    private Long linkedOrderId;
}
