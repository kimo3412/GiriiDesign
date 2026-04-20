import request from '../utils/request'

/**
 * 获取通知列表（分页）
 */
export const getNotifications = (pageNum = 1, pageSize = 20) => {
  return request({
    url: '/v1/app/notifications',
    method: 'GET',
    data: { pageNum, pageSize }
  })
}

/**
 * 获取未读通知数量
 */
export const getUnreadCount = () => {
  return request({
    url: '/v1/app/notifications/unread-count',
    method: 'GET'
  })
}

/**
 * 标记单条通知为已读
 */
export const markAsRead = (id) => {
  return request({
    url: `/v1/app/notifications/${id}/read`,
    method: 'PUT'
  })
}

/**
 * 全部标记为已读
 */
export const markAllAsRead = () => {
  return request({
    url: '/v1/app/notifications/read-all',
    method: 'PUT'
  })
}
