package com.designstudio.chat.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 聊天消息实体
 */
@Data
@TableName("ds_chat_message")
public class DsChatMessage {

    @TableId(type = IdType.AUTO)
    private Long messageId;

    /** 关联订单ID */
    private Long orderId;

    /** 发送方类型: client / admin */
    private String senderType;

    /** 发送人ID */
    private Long senderId;

    /** 消息内容 */
    private String content;

    /** 消息类型: text / image */
    private String msgType;

    /** 是否已读 */
    private Integer isRead;

    /** 发送时间 */
    private LocalDateTime createTime;
}
