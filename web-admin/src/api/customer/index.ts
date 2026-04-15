import { Alova } from '@/utils/http/alova/index';

export interface CustomerItem {
  userId: number;
  nickname?: string;
  avatarUrl?: string;
  phone?: string;
  status?: number;
  lastLoginTime?: string;
  createTime?: string;
  addressCount?: number;
  defaultAddress?: string;
}

export interface CustomerAddressItem {
  addressId: number;
  userId: number;
  nickname?: string;
  userPhone?: string;
  receiverName?: string;
  phone?: string;
  province?: string;
  city?: string;
  district?: string;
  detailAddress?: string;
  isDefault?: boolean;
  createTime?: string;
}

export function getCustomerList(params: any) {
  return Alova.Get<any>('/v1/admin/customers', { params });
}

export function getCustomerAddressList(params: any) {
  return Alova.Get<any>('/v1/admin/customers/addresses', { params });
}
