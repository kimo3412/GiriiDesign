import { Alova } from '@/utils/http/alova/index';

export interface DashboardData {
  totalUsers: number;
  totalOrders: number;
  totalRevenue: number;
  activeOrders: number;
  monthOrders: number;
  monthRevenue: number;
  pendingRequests: number;
  lowStockMaterials: number;
  orderStatusDistribution: Array<{ status: number; count: number }>;
  dailyOrderTrend: Array<{ date: string; order_count: number; revenue: number }>;
  categoryRank: Array<{ category_name: string; order_count: number; revenue: number }>;
  monthlyRevenueTrend: Array<{ month: string; order_count: number; revenue: number }>;
}

/** 获取经营看板数据 */
export const getDashboardData = () => {
  return Alova.Get<DashboardData>('/v1/admin/statistics/dashboard');
};
