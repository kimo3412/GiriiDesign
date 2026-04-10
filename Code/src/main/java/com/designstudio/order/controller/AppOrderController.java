package com.designstudio.order.controller;

import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderProgress;
import com.designstudio.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/v1/app/orders")
@RequiredArgsConstructor
@Tag(name = "C端订单")
public class AppOrderController {

    private final OrderService orderService;

    @GetMapping("/my")
    @Operation(summary = "我的订单列表")
    public R<List<DsOrder>> myOrders(@RequestParam(required = false) Integer status) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) {
            return R.fail("未登录");
        }
        return R.ok(orderService.getMyOrders(userId, status));
    }

    @GetMapping("/{id}")
    @Operation(summary = "订单详情")
    public R<OrderController.OrderDetailVO> detail(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) {
            return R.fail("未登录");
        }

        OrderController.OrderDetailVO vo = orderService.getAppOrderDetail(id, userId);
        if (vo == null) {
            return R.fail("订单不存在或无权查看");
        }
        return R.ok(vo);
    }

    @GetMapping("/{id}/timeline")
    @Operation(summary = "订单流程时间线")
    public R<OrderTimelineVO> timeline(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) {
            return R.fail("未登录");
        }

        OrderTimelineVO vo = orderService.getOrderTimeline(id, userId);
        if (vo == null) {
            return R.fail("订单不存在或无权查看");
        }
        return R.ok(vo);
    }

    @PostMapping("/{id}/pay")
    @Operation(summary = "模拟支付定金或尾款")
    public R<Void> payOrder(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) {
            return R.fail("未登录");
        }

        try {
            orderService.payOrder(id, userId);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/{id}/confirm")
    @Operation(summary = "确认收货并完成订单")
    public R<Void> confirmOrder(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) {
            return R.fail("未登录");
        }

        try {
            orderService.confirm(id, userId);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @Data
    public static class OrderTimelineVO {
        private DsOrder order;
        private List<DsWorkflowStep> workflowSteps;
        private List<DsOrderProgress> progressList;
        private List<TimelineEventVO> timelineEvents;
        private Integer currentStepIndex;
        private String currentStepName;
        private Integer hasRollback;
        private List<FormEntryVO> currentStepFormEntries;
        private Boolean isOverdue;
        private Integer overdueDays;
        private String expectedDateText;
        private Integer currentStepElapsedDays;
        private Integer currentStepExpectedDays;
    }

    @Data
    public static class TimelineEventVO {
        private Long progressId;
        private Long stepId;
        private String stepName;
        private String description;
        private String imageUrls;
        private LocalDateTime createTime;
        private String eventType;
        private String eventLabel;
        private List<FormEntryVO> formEntries;
        private String operatorName;
    }

    @Data
    public static class FormEntryVO {
        private String key;
        private String label;
        private String value;
        private String unit;
    }
}
