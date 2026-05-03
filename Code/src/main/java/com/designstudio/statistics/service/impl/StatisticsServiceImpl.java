package com.designstudio.statistics.service.impl;

import com.designstudio.common.security.LoginHelper;
import com.designstudio.common.security.LoginUser;
import com.designstudio.statistics.controller.StatisticsController;
import com.designstudio.statistics.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Collections;
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
        DashboardScope scope = resolveDashboardScope();
        StatisticsController.DashboardVO vo = new StatisticsController.DashboardVO();

        Integer totalUsers = queryInt(
                "SELECT COUNT(DISTINCT user_id) FROM ds_order WHERE del_flag = 0" + scope.orderCondition,
                scope.orderParams);
        vo.setTotalUsers(totalUsers);

        Integer totalOrders = queryInt(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0" + scope.orderCondition,
                scope.orderParams);
        vo.setTotalOrders(totalOrders);

        BigDecimal totalRevenue = queryDecimal(
                "SELECT COALESCE(SUM(paid_amount), 0) FROM ds_order WHERE del_flag = 0" + scope.orderCondition,
                scope.orderParams);
        vo.setTotalRevenue(totalRevenue);

        BigDecimal averageOrderAmount = queryDecimal(
                "SELECT COALESCE(AVG(total_amount), 0) FROM ds_order WHERE del_flag = 0" + scope.orderCondition,
                scope.orderParams);
        vo.setAverageOrderAmount(averageOrderAmount);

        Integer activeOrders = queryInt(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0 AND status IN (1,2,3)" + scope.orderCondition,
                scope.orderParams);
        vo.setActiveOrders(activeOrders);

        Integer monthOrders = queryInt(
                "SELECT COUNT(*) FROM ds_order WHERE del_flag = 0 " +
                        "AND create_time >= DATE_FORMAT(NOW(), '%Y-%m-01')" + scope.orderCondition,
                scope.orderParams);
        vo.setMonthOrders(monthOrders);

        BigDecimal monthRevenue = queryDecimal(
                "SELECT COALESCE(SUM(paid_amount), 0) FROM ds_order WHERE del_flag = 0 " +
                        "AND create_time >= DATE_FORMAT(NOW(), '%Y-%m-01')" + scope.orderCondition,
                scope.orderParams);
        vo.setMonthRevenue(monthRevenue);

        Integer pendingRequests = queryInt(
                "SELECT COUNT(*) FROM ds_order_request WHERE del_flag = 0 AND status = 0" +
                        scope.requestCategoryCondition,
                scope.requestCategoryParams);
        vo.setPendingRequests(pendingRequests);

        Integer lowStockMaterials = scope.isDesignerOnly
                ? 0
                : queryInt("SELECT COUNT(*) FROM ds_material WHERE del_flag = 0 AND stock <= warning_stock",
                Collections.emptyList());
        vo.setLowStockMaterials(lowStockMaterials);

        Integer repeatCustomers = queryInt(
                "SELECT COUNT(*) FROM (" +
                        "SELECT user_id FROM ds_order WHERE del_flag = 0" + scope.orderCondition +
                        " GROUP BY user_id HAVING COUNT(*) > 1" +
                        ") t",
                scope.orderParams);
        vo.setRepeatCustomers(repeatCustomers);
        if (totalUsers > 0) {
            vo.setRepeatCustomerRate(BigDecimal.valueOf(repeatCustomers * 100.0 / totalUsers)
                    .setScale(2, RoundingMode.HALF_UP));
        } else {
            vo.setRepeatCustomerRate(BigDecimal.ZERO);
        }

        List<Map<String, Object>> statusDist = queryList(
                "SELECT CAST(status AS SIGNED) AS status, COUNT(*) AS count " +
                        "FROM ds_order WHERE del_flag = 0" + scope.orderCondition +
                        " GROUP BY status ORDER BY status",
                scope.orderParams);
        vo.setOrderStatusDistribution(statusDist);

        List<Map<String, Object>> dailyTrend = queryList(
                "SELECT DATE(create_time) AS date, COUNT(*) AS order_count, " +
                        "COALESCE(SUM(total_amount), 0) AS revenue " +
                        "FROM ds_order WHERE del_flag = 0 " +
                        "AND create_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)" +
                        scope.orderCondition +
                        " GROUP BY DATE(create_time) ORDER BY date",
                scope.orderParams);
        vo.setDailyOrderTrend(dailyTrend);

        List<Map<String, Object>> categoryRank = queryList(
                "SELECT c.name AS category_name, COUNT(o.order_id) AS order_count, " +
                        "COALESCE(SUM(o.total_amount), 0) AS revenue " +
                        "FROM ds_order o LEFT JOIN ds_category c ON o.category_id = c.category_id " +
                        "WHERE o.del_flag = 0" + scope.aliasedOrderCondition +
                        " GROUP BY o.category_id, c.name " +
                        "ORDER BY order_count DESC LIMIT 10",
                scope.aliasedOrderParams);
        vo.setCategoryRank(categoryRank);

        List<Map<String, Object>> monthlyRevenue = queryList(
                "SELECT DATE_FORMAT(create_time, '%Y-%m') AS month, " +
                        "COUNT(*) AS order_count, COALESCE(SUM(paid_amount), 0) AS revenue " +
                        "FROM ds_order WHERE del_flag = 0 " +
                        "AND create_time >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)" +
                        scope.orderCondition +
                        " GROUP BY month ORDER BY month",
                scope.orderParams);
        vo.setMonthlyRevenueTrend(monthlyRevenue);

        List<Map<String, Object>> conversionMetrics = queryList(
                "SELECT c.name AS category_name, " +
                        "COALESCE(req.request_count, 0) AS request_count, " +
                        "COALESCE(req.converted_count, 0) AS converted_count, " +
                        "COALESCE(ord.completed_count, 0) AS completed_count " +
                        "FROM ds_category c " +
                        "LEFT JOIN (" +
                        "  SELECT r.category_id, " +
                        "         COUNT(*) AS request_count, " +
                        "         SUM(CASE WHEN r.status = 1 " +
                        (scope.isDesignerOnly ? "AND o.designer_id = ? " : "") +
                        "THEN 1 ELSE 0 END) AS converted_count " +
                        "  FROM ds_order_request r " +
                        "  LEFT JOIN ds_order o ON r.linked_order_id = o.order_id AND o.del_flag = 0 " +
                        "  WHERE r.del_flag = 0" + scope.conversionRequestCategoryCondition +
                        "  GROUP BY r.category_id" +
                        ") req ON c.category_id = req.category_id " +
                        "LEFT JOIN (" +
                        "  SELECT category_id, " +
                        "         SUM(CASE WHEN status = 4 THEN 1 ELSE 0 END) AS completed_count " +
                        "  FROM ds_order " +
                        "  WHERE del_flag = 0" + scope.orderCondition +
                        "  GROUP BY category_id" +
                        ") ord ON c.category_id = ord.category_id " +
                        "WHERE c.del_flag = 0" + scope.categoryCondition +
                        " ORDER BY request_count DESC, converted_count DESC, c.category_id ASC",
                scope.conversionParams);
        vo.setConversionMetrics(conversionMetrics);

        List<Map<String, Object>> designerEfficiency = queryList(
                "SELECT COALESCE(a.nickname, a.username, CONCAT('设计师#', o.designer_id)) AS designer_name, " +
                        "COUNT(o.order_id) AS total_orders, " +
                        "ROUND(AVG(CASE WHEN o.finish_time IS NOT NULL THEN TIMESTAMPDIFF(DAY, o.create_time, o.finish_time) END), 2) AS avg_cycle_days, " +
                        "SUM(CASE WHEN o.finish_time IS NOT NULL AND o.expected_date IS NOT NULL AND DATE(o.finish_time) > o.expected_date THEN 1 ELSE 0 END) AS overtime_count " +
                        "FROM ds_order o " +
                        "LEFT JOIN sys_admin a ON o.designer_id = a.admin_id " +
                        "WHERE o.del_flag = 0 AND o.designer_id IS NOT NULL" + scope.aliasedOrderCondition +
                        " GROUP BY o.designer_id, a.nickname, a.username " +
                        "ORDER BY total_orders DESC, avg_cycle_days ASC",
                scope.aliasedOrderParams);
        vo.setDesignerEfficiency(designerEfficiency);

        List<Map<String, Object>> workflowBottlenecks = queryList(
                "SELECT COALESCE(s.step_name, CONCAT('节点#', t.step_id)) AS step_name, " +
                        "ROUND(AVG(t.stay_days), 2) AS avg_stay_days, " +
                        "COUNT(*) AS sample_count " +
                        "FROM (" +
                        "  SELECT p.order_id, p.step_id, TIMESTAMPDIFF(DAY, p.create_time, COALESCE((" +
                        "    SELECT MIN(p2.create_time) FROM ds_order_progress p2 " +
                        "    WHERE p2.order_id = p.order_id AND p2.create_time > p.create_time" +
                        "  ), NOW())) AS stay_days " +
                        "  FROM ds_order_progress p " +
                        "  INNER JOIN ds_order o ON p.order_id = o.order_id AND o.del_flag = 0 " +
                        "  WHERE p.del_flag = 0 AND p.step_id IS NOT NULL" + scope.aliasedOrderCondition +
                        ") t " +
                        "LEFT JOIN ds_workflow_step s ON t.step_id = s.step_id " +
                        "GROUP BY t.step_id, s.step_name " +
                        "ORDER BY avg_stay_days DESC, sample_count DESC " +
                        "LIMIT 10",
                scope.aliasedOrderParams);
        vo.setWorkflowBottlenecks(workflowBottlenecks);

        return vo;
    }

    private DashboardScope resolveDashboardScope() {
        LoginUser loginUser = LoginHelper.getLoginUser();
        if (loginUser == null || loginUser.getAdminId() == null) {
            return DashboardScope.global();
        }

        List<String> roleKeys = loginUser.getRoleKeys();
        if (roleKeys == null || roleKeys.isEmpty()) {
            return DashboardScope.global();
        }

        boolean isAdmin = roleKeys.stream().anyMatch(role -> "admin".equalsIgnoreCase(role));
        boolean isDesigner = roleKeys.stream().anyMatch(role -> "designer".equalsIgnoreCase(role));
        if (!isDesigner || isAdmin) {
            return DashboardScope.global();
        }

        Long designerId = loginUser.getAdminId();
        List<Long> categoryIds = jdbcTemplate.queryForList(
                "SELECT category_id FROM ds_designer_category WHERE admin_id = ?",
                Long.class,
                designerId);
        return DashboardScope.designer(designerId, categoryIds);
    }

    private Integer queryInt(String sql, List<Object> params) {
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, params.toArray());
        return result != null ? result : 0;
    }

    private BigDecimal queryDecimal(String sql, List<Object> params) {
        BigDecimal result = jdbcTemplate.queryForObject(sql, BigDecimal.class, params.toArray());
        return result != null ? result : BigDecimal.ZERO;
    }

    private List<Map<String, Object>> queryList(String sql, List<Object> params) {
        return jdbcTemplate.queryForList(sql, params.toArray());
    }

    private static String inClause(int size) {
        if (size <= 0) {
            return "";
        }
        return String.join(",", Collections.nCopies(size, "?"));
    }

    private static final class DashboardScope {
        private final boolean isDesignerOnly;
        private final String orderCondition;
        private final List<Object> orderParams;
        private final String aliasedOrderCondition;
        private final List<Object> aliasedOrderParams;
        private final String requestCategoryCondition;
        private final List<Object> requestCategoryParams;
        private final String categoryCondition;
        private final List<Object> categoryParams;
        private final List<Object> conversionParams;
        private final String conversionRequestCategoryCondition;

        private DashboardScope(
                boolean isDesignerOnly,
                String orderCondition,
                List<Object> orderParams,
                String aliasedOrderCondition,
                List<Object> aliasedOrderParams,
                String requestCategoryCondition,
                List<Object> requestCategoryParams,
                String categoryCondition,
                List<Object> categoryParams,
                List<Object> conversionParams,
                String conversionRequestCategoryCondition) {
            this.isDesignerOnly = isDesignerOnly;
            this.orderCondition = orderCondition;
            this.orderParams = orderParams;
            this.aliasedOrderCondition = aliasedOrderCondition;
            this.aliasedOrderParams = aliasedOrderParams;
            this.requestCategoryCondition = requestCategoryCondition;
            this.requestCategoryParams = requestCategoryParams;
            this.categoryCondition = categoryCondition;
            this.categoryParams = categoryParams;
            this.conversionParams = conversionParams;
            this.conversionRequestCategoryCondition = conversionRequestCategoryCondition;
        }

        private static DashboardScope global() {
            return new DashboardScope(
                    false,
                    "",
                    Collections.emptyList(),
                    "",
                    Collections.emptyList(),
                    "",
                    Collections.emptyList(),
                    "",
                    Collections.emptyList(),
                    Collections.emptyList(),
                    "");
        }

        private static DashboardScope designer(Long designerId, List<Long> categoryIds) {
            List<Object> orderParams = Collections.singletonList(designerId);
            List<Object> categoryParams = new ArrayList<>();
            String requestCategoryCondition;
            String categoryCondition;

            if (categoryIds == null || categoryIds.isEmpty()) {
                requestCategoryCondition = " AND 1 = 0";
                categoryCondition = " AND 1 = 0";
            } else {
                categoryParams.addAll(categoryIds);
                String placeholders = inClause(categoryIds.size());
                requestCategoryCondition = " AND category_id IN (" + placeholders + ")";
                categoryCondition = " AND c.category_id IN (" + placeholders + ")";
            }

            String conversionRequestCategoryCondition;
            if (categoryIds == null || categoryIds.isEmpty()) {
                conversionRequestCategoryCondition = " AND 1 = 0";
            } else {
                conversionRequestCategoryCondition = " AND r.category_id IN (" + inClause(categoryIds.size()) + ")";
            }

            List<Object> conversionParams = new ArrayList<>();
            conversionParams.add(designerId);
            conversionParams.addAll(categoryParams);
            conversionParams.add(designerId);
            conversionParams.addAll(categoryParams);

            return new DashboardScope(
                    true,
                    " AND designer_id = ?",
                    orderParams,
                    " AND o.designer_id = ?",
                    orderParams,
                    requestCategoryCondition,
                    categoryParams,
                    categoryCondition,
                    categoryParams,
                    conversionParams,
                    conversionRequestCategoryCondition);
        }
    }
}
