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
     * 查询有未读消息的订单列表（B端用）
     */
    @Select("SELECT m.order_id, o.order_no, " +
            "COUNT(CASE WHEN m.is_read = 0 AND m.sender_type = 'client' THEN 1 END) AS unread_count, " +
            "MAX(m.create_time) AS last_time, " +
            "(SELECT content FROM ds_chat_message WHERE order_id = m.order_id ORDER BY create_time DESC LIMIT 1) AS last_content " +
            "FROM ds_chat_message m " +
            "LEFT JOIN ds_order o ON m.order_id = o.order_id " +
            "GROUP BY m.order_id, o.order_no " +
            "ORDER BY last_time DESC")
    List<Map<String, Object>> selectConversationList();
}
