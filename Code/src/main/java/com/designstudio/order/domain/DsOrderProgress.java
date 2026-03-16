package com.designstudio.order.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 订单进度表
 */
@Data
@TableName("ds_order_progress")
public class DsOrderProgress implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long progressId;

    /** 所属订单 */
    private Long orderId;

    /** 对应工作流节点 */
    private Long stepId;

    /** 进度描述 */
    private String description;

    /** 进度图片(JSON数组) */
    private String imageUrls;

    /** 操作人ID */
    private Long operatorId;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 逻辑删除 */
    private Integer delFlag;
}
