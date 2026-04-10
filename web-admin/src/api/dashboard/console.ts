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
  averageOrderAmount: number;
  repeatCustomers: number;
  repeatCustomerRate: number;
  conversionMetrics: Array<{
    category_name: string;
    request_count: number;
    converted_count: number;
    completed_count: number;
  }>;
  designerEfficiency: Array<{
    designer_name: string;
    total_orders: number;
    avg_cycle_days: number;
    overtime_count: number;
  }>;
  workflowBottlenecks: Array<{
    step_name: string;
    avg_stay_days: number;
    sample_count: number;
  }>;
}

/** 获取经营看板数据 */
export const getDashboardData = () => {
  return Alova.Get<DashboardData>('/v1/admin/statistics/dashboard');
};
