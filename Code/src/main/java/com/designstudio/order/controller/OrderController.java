package com.designstudio.order.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.PageResult;
import com.designstudio.common.result.R;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderProgress;
import com.designstudio.order.service.OrderService;
import com.designstudio.supply.domain.DsBomItem;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 订单管理 Controller
 */
@RestController
@RequestMapping("/api/v1/admin/orders")
@RequiredArgsConstructor
@Tag(name = "订单管理")
public class OrderController {

    private final OrderService orderService;

    // ==================== 订单列表 & 详情 ====================

    @GetMapping
    @Operation(summary = "订单列表（支持分页、按状态/品类筛选）")
    public R<PageResult<DsOrder>> list(
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long designerId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") Long pageNum,
            @RequestParam(defaultValue = "10") Long pageSize) {
        IPage<DsOrder> page = orderService.listOrders(status, categoryId, designerId, keyword, pageNum, pageSize);
        return R.ok(PageResult.of(page.getRecords(), page.getTotal(), page.getCurrent(), page.getSize()));
    }

    @GetMapping("/{id}")
    @Operation(summary = "订单详情（360° 视图数据）")
    public R<OrderDetailVO> detail(@PathVariable Long id) {
        OrderDetailVO vo = orderService.getOrderDetail(id);
        if (vo == null) return R.fail("订单不存在");
        return R.ok(vo);
    }

    // ==================== 看板视图 ====================

    @GetMapping("/kanban")
    @Operation(summary = "订单看板数据（按品类分组，列=工作流节点）")
    public R<List<KanbanColumnVO>> kanban(@RequestParam(required = false) Long categoryId) {
        return R.ok(orderService.getKanbanData(categoryId));
    }

    // ==================== 订单操作 ====================

    @PostMapping("/{orderId}/advance")
    @Operation(summary = "推进订单到下一个工作流节点")
    @OperLog("推进订单节点")
    public R<Void> advance(@PathVariable Long orderId, @RequestBody AdvanceDTO dto) {
        try {
            orderService.advance(orderId, dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/{orderId}/block")
    @Operation(summary = "阻塞订单")
    @OperLog("阻塞订单")
    public R<Void> block(@PathVariable Long orderId, @RequestBody BlockDTO dto) {
        try {
            orderService.block(orderId, dto.getBlockReason());
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/{orderId}/unblock")
    @Operation(summary = "解除阻塞")
    @OperLog("解除订单阻塞")
    public R<Void> unblock(@PathVariable Long orderId) {
        try {
            orderService.unblock(orderId);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/{orderId}/cancel")
    @Operation(summary = "取消订单")
    @OperLog("取消订单")
    public R<Void> cancel(@PathVariable Long orderId, @RequestBody CancelDTO dto) {
        try {
            orderService.cancel(orderId, dto.getCancelReason());
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/{orderId}/delay")
    @Operation(summary = "登记延期原因并调整预计交付时间")
    @OperLog("订单延期")
    public R<Void> delay(@PathVariable Long orderId, @RequestBody DelayDTO dto) {
        try {
            orderService.delay(orderId, dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/{orderId}/ship")
    @Operation(summary = "标记订单已发货")
    @OperLog("订单发货")
    public R<Void> ship(@PathVariable Long orderId, @RequestBody(required = false) ActionDTO dto) {
        try {
            orderService.ship(orderId, dto != null ? dto.getDescription() : null);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    // ==================== BOM物料 ====================

    @GetMapping("/{orderId}/bom")
    @Operation(summary = "获取订单BOM物料明细")
    public R<List<DsBomItem>> bomList(@PathVariable Long orderId) {
        return R.ok(orderService.getOrderBom(orderId));
    }

    // ==================== 进度管理 ====================

    @GetMapping("/{orderId}/progress")
    @Operation(summary = "获取订单进度时间轴")
    public R<List<DsOrderProgress>> progressList(@PathVariable Long orderId) {
        return R.ok(orderService.getProgressList(orderId));
    }

    @PostMapping("/{orderId}/progress")
    @Operation(summary = "添加进度记录")
    @OperLog("添加订单进度")
    public R<Void> addProgress(@PathVariable Long orderId, @RequestBody ProgressDTO dto) {
        try {
            orderService.addProgress(orderId, dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    // ==================== VO / DTO ====================

    @Data
    public static class OrderDetailVO {
        private DsOrder order;
        private List<DsWorkflowStep> workflowSteps;
        private List<DsOrderProgress> progressList;
    }

    @Data
    public static class KanbanColumnVO {
        private Long stepId;
        private String stepName;
        private Integer stepOrder;
        private Long categoryId;
        private List<DsOrder> orders;
    }

    @Data
    public static class AdvanceDTO {
        private Long expectedCurrentStepId;
        private String description;
        private String imageUrls;
        private String formData;
    }

    @Data
    public static class BlockDTO {
        private String blockReason;
    }

    @Data
    public static class CancelDTO {
        private String cancelReason;
    }

    @Data
    public static class DelayDTO {
        private String delayReason;
        private java.time.LocalDate expectedDate;
        private String description;
    }

    @Data
    public static class ActionDTO {
        private String description;
    }

    @Data
    public static class ProgressDTO {
        private String description;
        private String imageUrls;
        private String formData;
    }
}
