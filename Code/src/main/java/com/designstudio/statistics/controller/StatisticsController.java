package com.designstudio.statistics.controller;

import com.designstudio.common.result.R;
import com.designstudio.statistics.service.StatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
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

    private final StatisticsService statisticsService;

    @GetMapping("/dashboard")
    @Operation(summary = "获取经营看板数据")
    public R<DashboardVO> getDashboard() {
        return R.ok(statisticsService.getDashboard());
    }

    @Data
    public static class DashboardVO {
        private Integer totalUsers;
        private Integer totalOrders;
        private BigDecimal totalRevenue;
        private Integer activeOrders;
        private Integer monthOrders;
        private BigDecimal monthRevenue;
        private Integer pendingRequests;
        private Integer lowStockMaterials;
        private List<Map<String, Object>> orderStatusDistribution;
        private List<Map<String, Object>> dailyOrderTrend;
        private List<Map<String, Object>> categoryRank;
        private List<Map<String, Object>> monthlyRevenueTrend;
    }
}
