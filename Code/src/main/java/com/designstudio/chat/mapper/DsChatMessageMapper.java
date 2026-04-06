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
     * 查询所有客户沟通会话列表（B端用）
     */
    @Select("SELECT m.user_id AS userId, u.nickname, u.avatar_url AS avatar, " +
            "COUNT(CASE WHEN m.is_read = 0 AND m.sender_type = 0 THEN 1 END) AS unreadCount, " +
            "MAX(m.create_time) AS lastTime, " +
            "(SELECT content FROM ds_chat_message WHERE user_id = m.user_id ORDER BY create_time DESC LIMIT 1) AS lastContent " +
            "FROM ds_chat_message m " +
            "LEFT JOIN ds_user u ON m.user_id = u.user_id " +
            "GROUP BY m.user_id, u.nickname, u.avatar_url " +
            "ORDER BY lastTime DESC")
    List<Map<String, Object>> selectConversationList();
}
