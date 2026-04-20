package com.designstudio.common.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.common.domain.Notification;
import org.apache.ibatis.annotations.Mapper;

/**
 * 站内通知 Mapper
 */
@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {
}
