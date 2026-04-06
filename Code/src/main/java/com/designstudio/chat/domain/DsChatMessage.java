package com.designstudio.chat.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 聊天消息实体（对齐真实表结构）
 *
 * 表字段:
 *   msg_id, user_id, sender_type(tinyint: 0=客户,1=设计师),
 *   sender_id, content_type(tinyint: 0=文本,1=图片), content,
 *   is_read, create_time, del_flag
 */
@Data
@TableName("ds_chat_message")
public class DsChatMessage {

    @TableId(type = IdType.AUTO)
    private Long msgId;

    /** 关联客户ID */
    private Long userId;

    /** 发送方类型: 0=客户, 1=设计师/管理员 */
    private Integer senderType;

    /** 发送人ID */
    private Long senderId;

    /** 消息类型: 0=文本, 1=图片 */
    private Integer contentType;

    /** 消息内容 */
    private String content;

    /** 是否已读 */
    private Integer isRead;

    /** 发送时间 */
    private LocalDateTime createTime;

    /** 逻辑删除 */
    private Integer delFlag;
}
