package com.designstudio.common.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 站内通知实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_notification")
public class Notification extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 接收用户ID */
    private Long userId;

    /** 通知标题 */
    private String title;

    /** 通知内容 */
    private String content;

    /** 通知类型: order_status / payment / workbench / system */
    private String type;

    /** 关联ID（如订单ID） */
    private Long relatedId;

    /** 关联类型: order / request */
    private String relatedType;

    /** 是否已读 (0=未读, 1=已读) */
    private Integer isRead;

    /** 创建时间 */
    private LocalDateTime createTime;
}
