package com.designstudio.statistics.service.impl;

import com.designstudio.statistics.controller.StatisticsController;
import com.designstudio.statistics.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
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

        BigDecimal averageOrderAmount = jdbcTemplate.queryForObject(
                "SELECT COALESCE(AVG(total_amount), 0) FROM ds_order WHERE del_flag = 0", BigDecimal.class);
        vo.setAverageOrderAmount(averageOrderAmount != null ? averageOrderAmount : BigDecimal.ZERO);

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

        Integer repeatCustomers = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM (" +
                        "SELECT user_id FROM ds_order WHERE del_flag = 0 GROUP BY user_id HAVING COUNT(*) > 1" +
                        ") t", Integer.class);
        vo.setRepeatCustomers(repeatCustomers != null ? repeatCustomers : 0);
        if (totalUsers != null && totalUsers > 0) {
            vo.setRepeatCustomerRate(BigDecimal.valueOf((repeatCustomers != null ? repeatCustomers : 0) * 100.0 / totalUsers)
                    .setScale(2, RoundingMode.HALF_UP));
        } else {
            vo.setRepeatCustomerRate(BigDecimal.ZERO);
        }

        // ============ 2. 图表数据 ============
        List<Map<String, Object>> statusDist = jdbcTemplate.queryForList(
                "SELECT CAST(status AS SIGNED) AS status, COUNT(*) AS count " +
                        "FROM ds_order WHERE del_flag = 0 GROUP BY status ORDER BY status");
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

        List<Map<String, Object>> conversionMetrics = jdbcTemplate.queryForList(
                "SELECT c.name AS category_name, " +
                        "COALESCE(req.request_count, 0) AS request_count, " +
                        "COALESCE(req.converted_count, 0) AS converted_count, " +
                        "COALESCE(ord.completed_count, 0) AS completed_count " +
                        "FROM ds_category c " +
                        "LEFT JOIN (" +
                        "  SELECT category_id, " +
                        "         COUNT(*) AS request_count, " +
                        "         SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS converted_count " +
                        "  FROM ds_order_request " +
                        "  WHERE del_flag = 0 " +
                        "  GROUP BY category_id" +
                        ") req ON c.category_id = req.category_id " +
                        "LEFT JOIN (" +
                        "  SELECT category_id, " +
                        "         SUM(CASE WHEN status = 4 THEN 1 ELSE 0 END) AS completed_count " +
                        "  FROM ds_order " +
                        "  WHERE del_flag = 0 " +
                        "  GROUP BY category_id" +
                        ") ord ON c.category_id = ord.category_id " +
                        "ORDER BY request_count DESC, converted_count DESC, c.category_id ASC");
        vo.setConversionMetrics(conversionMetrics);

        List<Map<String, Object>> designerEfficiency = jdbcTemplate.queryForList(
                "SELECT COALESCE(a.nickname, a.username, CONCAT('设计师#', o.designer_id)) AS designer_name, " +
                        "COUNT(o.order_id) AS total_orders, " +
                        "ROUND(AVG(CASE WHEN o.finish_time IS NOT NULL THEN TIMESTAMPDIFF(DAY, o.create_time, o.finish_time) END), 2) AS avg_cycle_days, " +
                        "SUM(CASE WHEN o.finish_time IS NOT NULL AND o.expected_date IS NOT NULL AND DATE(o.finish_time) > o.expected_date THEN 1 ELSE 0 END) AS overtime_count " +
                        "FROM ds_order o " +
                        "LEFT JOIN sys_admin a ON o.designer_id = a.admin_id " +
                        "WHERE o.del_flag = 0 AND o.designer_id IS NOT NULL " +
                        "GROUP BY o.designer_id, a.nickname, a.username " +
                        "ORDER BY total_orders DESC, avg_cycle_days ASC");
        vo.setDesignerEfficiency(designerEfficiency);

        List<Map<String, Object>> workflowBottlenecks = jdbcTemplate.queryForList(
                "SELECT COALESCE(s.step_name, CONCAT('节点#', t.step_id)) AS step_name, " +
                        "ROUND(AVG(t.stay_days), 2) AS avg_stay_days, " +
                        "COUNT(*) AS sample_count " +
                        "FROM (" +
                        "  SELECT p.order_id, p.step_id, TIMESTAMPDIFF(DAY, p.create_time, COALESCE((" +
                        "    SELECT MIN(p2.create_time) FROM ds_order_progress p2 " +
                        "    WHERE p2.order_id = p.order_id AND p2.create_time > p.create_time" +
                        "  ), NOW())) AS stay_days " +
                        "  FROM ds_order_progress p " +
                        "  WHERE p.del_flag = 0 AND p.step_id IS NOT NULL" +
                        ") t " +
                        "LEFT JOIN ds_workflow_step s ON t.step_id = s.step_id " +
                        "GROUP BY t.step_id, s.step_name " +
                        "ORDER BY avg_stay_days DESC, sample_count DESC " +
                        "LIMIT 10");
        vo.setWorkflowBottlenecks(workflowBottlenecks);

        return vo;
    }
}
