package com.designstudio.chat.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.chat.domain.DsChatMessage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 聊天消息 Mapper
 */
@Mapper
public interface DsChatMessageMapper extends BaseMapper<DsChatMessage> {

    /**
     * 查询所有客户沟通会话列表（B端用），按(user_id, order_id)分组
     */
    @Select("SELECT m.user_id AS userId, m.order_id AS orderId, " +
            "o.order_sn AS orderSn, " +
            "u.nickname, u.avatar_url AS avatar, " +
            "COUNT(CASE WHEN m.is_read = 0 AND m.sender_type = 0 THEN 1 END) AS unreadCount, " +
            "COUNT(CASE WHEN m.is_read = 0 AND m.sender_type = 0 AND m.content_type = 4 THEN 1 END) AS handoffCount, " +
            "MAX(m.create_time) AS lastTime, " +
            "(SELECT content FROM ds_chat_message m2 " +
            " WHERE m2.user_id = m.user_id AND (m2.order_id <=> m.order_id) " +
            " ORDER BY create_time DESC LIMIT 1) AS lastContent " +
            "FROM ds_chat_message m " +
            "LEFT JOIN ds_user u ON m.user_id = u.user_id " +
            "LEFT JOIN ds_order o ON m.order_id = o.order_id " +
            "GROUP BY m.user_id, m.order_id, o.order_sn, u.nickname, u.avatar_url " +
            "ORDER BY lastTime DESC")
    List<Map<String, Object>> selectConversationList();
}
