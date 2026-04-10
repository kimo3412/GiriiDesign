import { Alova } from '@/utils/http/alova/index';

/** 获取所有会话列表（含未读数，按订单分组） */
export const getConversations = () => {
  return Alova.Get<any>('/v1/admin/chat/conversations');
};

/** 获取某客户的聊天记录 */
export const getChatMessages = (userId: number, orderId?: number | null) => {
  const params: any = {};
  if (orderId != null) params.orderId = orderId;
  return Alova.Get<any>(`/v1/admin/chat/${userId}`, { params });
};

/** 标记某客户的消息为已读 */
export const markChatRead = (userId: number, orderId?: number | null) => {
  const params: any = {};
  if (orderId != null) params.orderId = orderId;
  return Alova.Put<any>(`/v1/admin/chat/${userId}/read`, null, { params });
};

/** 获取聊天客户的全景意向/订单一览 */
export const getUserSummary = (userId: number) => {
  return Alova.Get<any>(`/v1/admin/chat/user-summary/${userId}`);
};
