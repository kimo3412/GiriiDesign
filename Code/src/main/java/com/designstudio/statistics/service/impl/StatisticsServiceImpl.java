package com.designstudio.statistics.service.impl;

import com.designstudio.statistics.controller.StatisticsController;
import com.designstudio.statistics.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 数据统计 Service 实现
 */
@Service
@RequiredArgsConstructor
public class StatisticsServiceImpl implements StatisticsService {

    private final JdbcTemplate jdbcTemplate;

    @Override
    public StatisticsController.DashboardVO getDashboard() {
        StatisticsController.DashboardVO vo = new StatisticsController.DashboardVO();

        // ============ 1. 统计卡片数据 ============
        Integer totalUsers = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_user WHERE status = 1", Integer.class);
        vo.setTotalUsers(totalUsers != null ? totalUsers : 0);

        Integer totalOrders = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0", Integer.class);
        vo.setTotalOrders(totalOrders != null ? totalOrders : 0);

        BigDecimal totalRevenue = jdbcTemplate.queryForObject(
                "SELECT COALESCE(SUM(paid_amount), 0) FROM ds_order WHERE del_flag = 0", BigDecimal.class);
        vo.setTotalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO);

        Integer activeOrders = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0 AND status IN (1,2,3)", Integer.class);
        vo.setActiveOrders(activeOrders != null ? activeOrders : 0);

        Integer monthOrders = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0 AND create_time >= DATE_FORMAT(NOW(), '%Y-%m-01')", Integer.class);
        vo.setMonthOrders(monthOrders != null ? monthOrders : 0);

        BigDecimal monthRevenue = jdbcTemplate.queryForObject(
                "SELECT COALESCE(SUM(paid_amount), 0) FROM ds_order WHERE del_flag = 0 AND create_time >= DATE_FORMAT(NOW(), '%Y-%m-01')", BigDecimal.class);
        vo.setMonthRevenue(monthRevenue != null ? monthRevenue : BigDecimal.ZERO);

        Integer pendingRequests = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_order_request WHERE del_flag = 0 AND status = 0", Integer.class);
        vo.setPendingRequests(pendingRequests != null ? pendingRequests : 0);

        Integer lowStockMaterials = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_material WHERE del_flag = 0 AND stock <= warning_stock", Integer.class);
        vo.setLowStockMaterials(lowStockMaterials != null ? lowStockMaterials : 0);

        // ============ 2. 图表数据 ============
        List<Map<String, Object>> statusDist = jdbcTemplate.queryForList(
                "SELECT status, COUNT(*) AS count FROM ds_order WHERE del_flag = 0 GROUP BY status ORDER BY status");
        vo.setOrderStatusDistribution(statusDist);

        List<Map<String, Object>> dailyTrend = jdbcTemplate.queryForList(
                "SELECT DATE(create_time) AS date, COUNT(*) AS order_count, " +
                "COALESCE(SUM(total_amount), 0) AS revenue " +
                "FROM ds_order WHERE del_flag = 0 AND create_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
                "GROUP BY DATE(create_time) ORDER BY date");
        vo.setDailyOrderTrend(dailyTrend);

        List<Map<String, Object>> categoryRank = jdbcTemplate.queryForList(
                "SELECT c.name AS category_name, COUNT(o.order_id) AS order_count, " +
                "COALESCE(SUM(o.total_amount), 0) AS revenue " +
                "FROM ds_order o LEFT JOIN ds_category c ON o.category_id = c.category_id " +
                "WHERE o.del_flag = 0 GROUP BY o.category_id, c.name " +
                "ORDER BY order_count DESC LIMIT 10");
        vo.setCategoryRank(categoryRank);

        List<Map<String, Object>> monthlyRevenue = jdbcTemplate.queryForList(
                "SELECT DATE_FORMAT(create_time, '%Y-%m') AS month, " +
                "COUNT(*) AS order_count, COALESCE(SUM(paid_amount), 0) AS revenue " +
                "FROM ds_order WHERE del_flag = 0 AND create_time >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                "GROUP BY month ORDER BY month");
        vo.setMonthlyRevenueTrend(monthlyRevenue);

        return vo;
    }
}
