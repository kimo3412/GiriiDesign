package com.designstudio.statistics.controller;

import com.designstudio.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 数据分析 - 经营看板 API
 */
@RestController
@RequestMapping("/api/v1/admin/statistics")
@RequiredArgsConstructor
@Tag(name = "数据分析")
public class StatisticsController {

    private final JdbcTemplate jdbcTemplate;

    @GetMapping("/dashboard")
    @Operation(summary = "获取经营看板数据")
    public R<DashboardVO> getDashboard() {
        DashboardVO vo = new DashboardVO();

        // ============ 1. 统计卡片数据 ============

        // 总客户数
        Integer totalUsers = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_user WHERE status = 1", Integer.class);
        vo.setTotalUsers(totalUsers != null ? totalUsers : 0);

        // 总订单数
        Integer totalOrders = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0", Integer.class);
        vo.setTotalOrders(totalOrders != null ? totalOrders : 0);

        // 总营收
        BigDecimal totalRevenue = jdbcTemplate.queryForObject(
                "SELECT COALESCE(SUM(paid_amount), 0) FROM ds_order WHERE del_flag = 0", BigDecimal.class);
        vo.setTotalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO);

        // 进行中订单
        Integer activeOrders = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0 AND status IN (1,2,3)", Integer.class);
        vo.setActiveOrders(activeOrders != null ? activeOrders : 0);

        // 本月新增订单
        Integer monthOrders = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0 AND create_time >= DATE_FORMAT(NOW(), '%Y-%m-01')", Integer.class);
        vo.setMonthOrders(monthOrders != null ? monthOrders : 0);

        // 本月营收
        BigDecimal monthRevenue = jdbcTemplate.queryForObject(
                "SELECT COALESCE(SUM(paid_amount), 0) FROM ds_order WHERE del_flag = 0 AND create_time >= DATE_FORMAT(NOW(), '%Y-%m-01')", BigDecimal.class);
        vo.setMonthRevenue(monthRevenue != null ? monthRevenue : BigDecimal.ZERO);

        // 待处理意向
        Integer pendingRequests = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_order_request WHERE del_flag = 0 AND status = 0", Integer.class);
        vo.setPendingRequests(pendingRequests != null ? pendingRequests : 0);

        // 低库存物料
        Integer lowStockMaterials = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ds_material WHERE del_flag = 0 AND stock <= warning_stock", Integer.class);
        vo.setLowStockMaterials(lowStockMaterials != null ? lowStockMaterials : 0);

        // ============ 2. 订单状态分布（饼图） ============
        List<Map<String, Object>> statusDist = jdbcTemplate.queryForList(
                "SELECT status, COUNT(*) AS count FROM ds_order WHERE del_flag = 0 GROUP BY status ORDER BY status");
        vo.setOrderStatusDistribution(statusDist);

        // ============ 3. 近7天订单趋势（折线图） ============
        List<Map<String, Object>> dailyTrend = jdbcTemplate.queryForList(
                "SELECT DATE(create_time) AS date, COUNT(*) AS order_count, " +
                "COALESCE(SUM(total_amount), 0) AS revenue " +
                "FROM ds_order WHERE del_flag = 0 AND create_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
                "GROUP BY DATE(create_time) ORDER BY date");
        vo.setDailyOrderTrend(dailyTrend);

        // ============ 4. 品类订单排名（柱状图） ============
        List<Map<String, Object>> categoryRank = jdbcTemplate.queryForList(
                "SELECT c.name AS category_name, COUNT(o.order_id) AS order_count, " +
                "COALESCE(SUM(o.total_amount), 0) AS revenue " +
                "FROM ds_order o LEFT JOIN ds_category c ON o.category_id = c.category_id " +
                "WHERE o.del_flag = 0 GROUP BY o.category_id, c.name " +
                "ORDER BY order_count DESC LIMIT 10");
        vo.setCategoryRank(categoryRank);

        // ============ 5. 近6个月营收趋势（面积图） ============
        List<Map<String, Object>> monthlyRevenue = jdbcTemplate.queryForList(
                "SELECT DATE_FORMAT(create_time, '%Y-%m') AS month, " +
                "COUNT(*) AS order_count, COALESCE(SUM(paid_amount), 0) AS revenue " +
                "FROM ds_order WHERE del_flag = 0 AND create_time >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                "GROUP BY month ORDER BY month");
        vo.setMonthlyRevenueTrend(monthlyRevenue);

        return R.ok(vo);
    }

    @Data
    public static class DashboardVO {
        // 统计卡片
        private Integer totalUsers;
        private Integer totalOrders;
        private BigDecimal totalRevenue;
        private Integer activeOrders;
        private Integer monthOrders;
        private BigDecimal monthRevenue;
        private Integer pendingRequests;
        private Integer lowStockMaterials;
        // 图表数据
        private List<Map<String, Object>> orderStatusDistribution;
        private List<Map<String, Object>> dailyOrderTrend;
        private List<Map<String, Object>> categoryRank;
        private List<Map<String, Object>> monthlyRevenueTrend;
    }
}
