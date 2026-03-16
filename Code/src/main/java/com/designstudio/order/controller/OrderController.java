package com.designstudio.order.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.common.security.LoginUser;
import com.designstudio.config.domain.DsWorkflow;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.config.mapper.DsWorkflowMapper;
import com.designstudio.config.mapper.DsWorkflowStepMapper;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderProgress;
import com.designstudio.order.mapper.DsOrderMapper;
import com.designstudio.order.mapper.DsOrderProgressMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 订单管理 Controller
 */
@RestController
@RequestMapping("/api/v1/admin/orders")
@RequiredArgsConstructor
@Tag(name = "订单管理")
public class OrderController {

    private final DsOrderMapper orderMapper;
    private final DsOrderProgressMapper progressMapper;
    private final DsWorkflowMapper workflowMapper;
    private final DsWorkflowStepMapper stepMapper;

    // ==================== 订单列表 & 详情 ====================

    @GetMapping
    @Operation(summary = "订单列表（支持按状态/品类筛选）")
    public R<List<DsOrder>> list(
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long designerId) {

        LambdaQueryWrapper<DsOrder> wrapper = new LambdaQueryWrapper<>();
        if (status != null) {
            wrapper.eq(DsOrder::getStatus, status);
        }
        if (categoryId != null) {
            wrapper.eq(DsOrder::getCategoryId, categoryId);
        }
        if (designerId != null) {
            wrapper.eq(DsOrder::getDesignerId, designerId);
        }
        wrapper.orderByDesc(DsOrder::getCreateTime);
        return R.ok(orderMapper.selectList(wrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "订单详情（360° 视图数据）")
    public R<OrderDetailVO> detail(@PathVariable Long id) {
        DsOrder order = orderMapper.selectById(id);
        if (order == null) {
            return R.fail("订单不存在");
        }

        // 查询工作流节点
        List<DsWorkflowStep> allSteps = Collections.emptyList();
        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>().eq(DsWorkflow::getCategoryId, order.getCategoryId()));
        if (workflow != null) {
            allSteps = stepMapper.selectList(
                    new LambdaQueryWrapper<DsWorkflowStep>()
                            .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId())
                            .orderByAsc(DsWorkflowStep::getStepOrder));
        }

        // 查询进度列表
        List<DsOrderProgress> progressList = progressMapper.selectList(
                new LambdaQueryWrapper<DsOrderProgress>()
                        .eq(DsOrderProgress::getOrderId, id)
                        .orderByAsc(DsOrderProgress::getCreateTime));

        OrderDetailVO vo = new OrderDetailVO();
        vo.setOrder(order);
        vo.setWorkflowSteps(allSteps);
        vo.setProgressList(progressList);
        return R.ok(vo);
    }

    // ==================== 看板视图 ====================

    @GetMapping("/kanban")
    @Operation(summary = "订单看板数据（按品类分组，列=工作流节点）")
    public R<List<KanbanColumnVO>> kanban(@RequestParam(required = false) Long categoryId) {
        // 1. 查询所有生产中的订单
        LambdaQueryWrapper<DsOrder> orderWrapper = new LambdaQueryWrapper<DsOrder>()
                .eq(DsOrder::getStatus, 1); // 生产中
        if (categoryId != null) {
            orderWrapper.eq(DsOrder::getCategoryId, categoryId);
        }
        List<DsOrder> orders = orderMapper.selectList(orderWrapper);

        if (orders.isEmpty()) {
            return R.ok(Collections.emptyList());
        }

        // 2. 获取品类ID集合
        Set<Long> categoryIds = orders.stream().map(DsOrder::getCategoryId).collect(Collectors.toSet());

        // 3. 查询对应工作流和节点
        List<DsWorkflow> workflows = workflowMapper.selectList(
                new LambdaQueryWrapper<DsWorkflow>().in(DsWorkflow::getCategoryId, categoryIds));
        if (workflows.isEmpty()) {
            return R.ok(Collections.emptyList());
        }

        Set<Long> workflowIds = workflows.stream().map(DsWorkflow::getWorkflowId).collect(Collectors.toSet());
        List<DsWorkflowStep> allSteps = stepMapper.selectList(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .in(DsWorkflowStep::getWorkflowId, workflowIds)
                        .orderByAsc(DsWorkflowStep::getStepOrder));

        // 4. 组装看板数据：每列 = 一个工作流节点
        // 先按 workflowId -> categoryId 建立映射
        Map<Long, Long> workflowCategoryMap = workflows.stream()
                .collect(Collectors.toMap(DsWorkflow::getWorkflowId, DsWorkflow::getCategoryId));

        // 按 stepId 分组订单
        Map<Long, List<DsOrder>> ordersByStep = orders.stream()
                .filter(o -> o.getCurrentStepId() != null)
                .collect(Collectors.groupingBy(DsOrder::getCurrentStepId));

        List<KanbanColumnVO> columns = allSteps.stream().map(step -> {
            KanbanColumnVO col = new KanbanColumnVO();
            col.setStepId(step.getStepId());
            col.setStepName(step.getStepName());
            col.setStepOrder(step.getStepOrder());
            col.setOrders(ordersByStep.getOrDefault(step.getStepId(), Collections.emptyList()));
            return col;
        }).collect(Collectors.toList());

        return R.ok(columns);
    }

    // ==================== 订单操作 ====================

    @PostMapping("/{orderId}/advance")
    @Operation(summary = "推进订单到下一个工作流节点")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> advance(@PathVariable Long orderId, @RequestBody AdvanceDTO dto) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) return R.fail("订单不存在");
        if (order.getStatus() != 1) return R.fail("只有生产中的订单才能推进");
        if (order.getIsBlocked() != null && order.getIsBlocked() == 1) return R.fail("订单已阻塞，请先解除阻塞");

        // 查询工作流
        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>().eq(DsWorkflow::getCategoryId, order.getCategoryId()));
        if (workflow == null) return R.fail("该品类未配置工作流");

        List<DsWorkflowStep> steps = stepMapper.selectList(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId())
                        .orderByAsc(DsWorkflowStep::getStepOrder));

        if (steps.isEmpty()) return R.fail("工作流没有节点");

        // 确定下一步
        Long currentStepId = order.getCurrentStepId();
        DsWorkflowStep nextStep = null;

        if (currentStepId == null) {
            // 还没有开始，进入第一个节点
            nextStep = steps.get(0);
        } else {
            for (int i = 0; i < steps.size(); i++) {
                if (steps.get(i).getStepId().equals(currentStepId)) {
                    if (i + 1 < steps.size()) {
                        nextStep = steps.get(i + 1);
                    }
                    break;
                }
            }
        }

        if (nextStep == null) {
            // 已经是最后一步了，标记为完成
            order.setStatus(2); // 待发货
            order.setFinishTime(LocalDateTime.now());
            orderMapper.updateById(order);
            return R.ok();
        }

        // 更新到下一步
        order.setCurrentStepId(nextStep.getStepId());
        orderMapper.updateById(order);

        // 记录进度
        LoginUser loginUser = LoginHelper.getLoginUser();
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(nextStep.getStepId());
        progress.setDescription(dto.getDescription() != null ? dto.getDescription()
                : "推进至节点：" + nextStep.getStepName());
        progress.setImageUrls(dto.getImageUrls());
        progress.setOperatorId(loginUser.getAdminId());
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);

        return R.ok();
    }

    @PostMapping("/{orderId}/block")
    @Operation(summary = "阻塞订单")
    public R<Void> block(@PathVariable Long orderId, @RequestBody BlockDTO dto) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) return R.fail("订单不存在");

        order.setIsBlocked(1);
        order.setBlockReason(dto.getBlockReason());
        orderMapper.updateById(order);
        return R.ok();
    }

    @PostMapping("/{orderId}/unblock")
    @Operation(summary = "解除阻塞")
    public R<Void> unblock(@PathVariable Long orderId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) return R.fail("订单不存在");

        order.setIsBlocked(0);
        order.setBlockReason(null);
        orderMapper.updateById(order);
        return R.ok();
    }

    // ==================== 进度管理 ====================

    @GetMapping("/{orderId}/progress")
    @Operation(summary = "获取订单进度时间轴")
    public R<List<DsOrderProgress>> progressList(@PathVariable Long orderId) {
        List<DsOrderProgress> list = progressMapper.selectList(
                new LambdaQueryWrapper<DsOrderProgress>()
                        .eq(DsOrderProgress::getOrderId, orderId)
                        .orderByAsc(DsOrderProgress::getCreateTime));
        return R.ok(list);
    }

    @PostMapping("/{orderId}/progress")
    @Operation(summary = "添加进度记录")
    public R<Void> addProgress(@PathVariable Long orderId, @RequestBody ProgressDTO dto) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) return R.fail("订单不存在");

        LoginUser loginUser = LoginHelper.getLoginUser();
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(order.getCurrentStepId());
        progress.setDescription(dto.getDescription());
        progress.setImageUrls(dto.getImageUrls());
        progress.setOperatorId(loginUser.getAdminId());
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);
        return R.ok();
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
        private List<DsOrder> orders;
    }

    @Data
    public static class AdvanceDTO {
        private String description;
        private String imageUrls;
    }

    @Data
    public static class BlockDTO {
        private String blockReason;
    }

    @Data
    public static class ProgressDTO {
        private String description;
        private String imageUrls;
    }
}
