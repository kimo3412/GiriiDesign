import { Alova } from '@/utils/http/alova/index';

/** 获取所有会话列表（含未读数） */
export const getConversations = () => {
  return Alova.Get<any>('/v1/admin/chat/conversations');
};

/** 获取某订单的聊天记录 */
export const getChatMessages = (orderId: number) => {
  return Alova.Get<any>(`/v1/admin/chat/${orderId}`);
};

/** 标记某订单的客户消息为已读 */
export const markChatRead = (orderId: number) => {
  return Alova.Put<any>(`/v1/admin/chat/${orderId}/read`);
};
