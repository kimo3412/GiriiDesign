package com.designstudio.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.common.security.LoginUser;
import com.designstudio.config.domain.DsCustomField;
import com.designstudio.config.domain.DsWorkflow;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.config.mapper.DsCustomFieldMapper;
import com.designstudio.config.mapper.DsWorkflowMapper;
import com.designstudio.config.mapper.DsWorkflowStepMapper;
import com.designstudio.customer.domain.DsUser;
import com.designstudio.customer.mapper.DsUserMapper;
import com.designstudio.order.controller.AppOrderController;
import com.designstudio.order.controller.OrderController;
import com.designstudio.order.controller.WorkbenchController;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderProgress;
import com.designstudio.order.mapper.DsOrderMapper;
import com.designstudio.order.mapper.DsOrderProgressMapper;
import com.designstudio.order.service.OrderService;
import com.designstudio.common.service.NotificationService;
import com.designstudio.supply.domain.DsBomItem;
import com.designstudio.supply.domain.DsMaterial;
import com.designstudio.supply.mapper.DsBomItemMapper;
import com.designstudio.supply.mapper.DsMaterialMapper;
import com.designstudio.system.domain.SysAdmin;
import com.designstudio.system.mapper.SysAdminMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final DsOrderMapper orderMapper;
    private final DsOrderProgressMapper progressMapper;
    private final DsCustomFieldMapper customFieldMapper;
    private final DsWorkflowMapper workflowMapper;
    private final DsWorkflowStepMapper stepMapper;
    private final DsUserMapper userMapper;
    private final SysAdminMapper adminMapper;
    private final DsBomItemMapper bomItemMapper;
    private final DsMaterialMapper materialMapper;
    private final ObjectMapper objectMapper;
    private final NotificationService notificationService;

    @Override
    public IPage<DsOrder> listOrders(Integer status, Long categoryId, Long designerId, Long pageNum, Long pageSize) {
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
        applyDesignerScope(wrapper);
        wrapper.orderByDesc(DsOrder::getCreateTime);
        Page<DsOrder> page = new Page<>(pageNum, pageSize);
        IPage<DsOrder> result = orderMapper.selectPage(page, wrapper);
        fillOrderDisplayNames(result.getRecords());
        return result;
    }

    @Override
    public OrderController.OrderDetailVO getOrderDetail(Long orderId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            return null;
        }
        ensureDesignerCanAccess(order);
        fillOrderDisplayName(order);

        OrderController.OrderDetailVO vo = new OrderController.OrderDetailVO();
        vo.setOrder(order);
        vo.setWorkflowSteps(getWorkflowStepsByCategory(order.getCategoryId()));
        vo.setProgressList(getProgressList(orderId));
        return vo;
    }

    @Override
    public List<OrderController.KanbanColumnVO> getKanbanData(Long categoryId) {
        LambdaQueryWrapper<DsOrder> orderWrapper = new LambdaQueryWrapper<DsOrder>()
                .eq(DsOrder::getStatus, 1);
        if (categoryId != null) {
            orderWrapper.eq(DsOrder::getCategoryId, categoryId);
        }
        applyDesignerScope(orderWrapper);
        List<DsOrder> orders = orderMapper.selectList(orderWrapper);
        if (orders.isEmpty()) {
            return Collections.emptyList();
        }

        Set<Long> categoryIds = orders.stream().map(DsOrder::getCategoryId).collect(Collectors.toSet());
        List<DsWorkflow> workflows = workflowMapper.selectList(
                new LambdaQueryWrapper<DsWorkflow>().in(DsWorkflow::getCategoryId, categoryIds));
        if (workflows.isEmpty()) {
            return Collections.emptyList();
        }

        Set<Long> workflowIds = workflows.stream().map(DsWorkflow::getWorkflowId).collect(Collectors.toSet());
        List<DsWorkflowStep> allSteps = stepMapper.selectList(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .in(DsWorkflowStep::getWorkflowId, workflowIds)
                        .orderByAsc(DsWorkflowStep::getStepOrder));

        Map<Long, Long> workflowCategoryMap = workflows.stream()
                .collect(Collectors.toMap(DsWorkflow::getWorkflowId, DsWorkflow::getCategoryId));
        Map<Long, List<DsOrder>> ordersByStep = orders.stream()
                .filter(order -> order.getCurrentStepId() != null)
                .collect(Collectors.groupingBy(DsOrder::getCurrentStepId));

        Map<Long, Long> stepCategoryMap = new HashMap<>();
        for (DsWorkflowStep step : allSteps) {
            stepCategoryMap.put(step.getStepId(), workflowCategoryMap.get(step.getWorkflowId()));
        }

        List<OrderController.KanbanColumnVO> columns = allSteps.stream().map(step -> {
            OrderController.KanbanColumnVO col = new OrderController.KanbanColumnVO();
            col.setStepId(step.getStepId());
            col.setStepName(step.getStepName());
            col.setStepOrder(step.getStepOrder());
            col.setCategoryId(stepCategoryMap.get(step.getStepId()));
            col.setOrders(ordersByStep.getOrDefault(step.getStepId(), Collections.emptyList()));
            return col;
        }).collect(Collectors.toList());
        columns.forEach(column -> fillOrderDisplayNames(column.getOrders()));
        return columns;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void advance(Long orderId, OrderController.AdvanceDTO dto) {
        DsOrder order = requireOrder(orderId);
        assertExpectedCurrentStep(order, dto != null ? dto.getExpectedCurrentStepId() : null);
        if (order.getStatus() != 1) {
            throw new RuntimeException("只有生产中的订单才能推进");
        }
        if (order.getIsBlocked() != null && order.getIsBlocked() == 1) {
            throw new RuntimeException("订单已阻塞，请先解除阻塞");
        }

        List<DsWorkflowStep> steps = requireWorkflowSteps(order.getCategoryId());
        DsWorkflowStep nextStep = resolveNextStep(steps, order.getCurrentStepId());
        if (nextStep == null) {
            finishOrder(order, dto);
            return;
        }

        order.setCurrentStepId(nextStep.getStepId());
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);

        LoginUser loginUser = LoginHelper.getLoginUser();
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(nextStep.getStepId());
        progress.setDescription(StringUtils.hasText(dto.getDescription())
                ? dto.getDescription()
                : "推进至节点：" + nextStep.getStepName());
        progress.setImageUrls(normalizeJsonField(dto.getImageUrls()));
        progress.setFormData(normalizeJsonField(dto.getFormData()));
        progress.setOperatorId(loginUser != null ? loginUser.getAdminId() : null);
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);

        // 通知客户节点推进
        if (order.getUserId() != null) {
            notificationService.sendToUser(order.getUserId(),
                    "订单进度更新",
                    "您的订单已推进至新节点：" + nextStep.getStepName(),
                    "workbench", orderId, "order");
        }
    }

    @Override
    public void block(Long orderId, String blockReason) {
        DsOrder order = requireOrder(orderId);
        order.setIsBlocked(1);
        order.setBlockReason(blockReason);
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);

        if (order.getUserId() != null) {
            notificationService.sendToUser(order.getUserId(),
                    "订单阻塞通知",
                    "您的订单生产暂时受阻：" + blockReason,
                    "order_status", orderId, "order");
        }
    }

    @Override
    public void unblock(Long orderId) {
        DsOrder order = requireOrder(orderId);
        order.setIsBlocked(0);
        order.setBlockReason(null);
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);

        if (order.getUserId() != null) {
            notificationService.sendToUser(order.getUserId(),
                    "订单恢复通知",
                    "您的订单已解除阻塞，生产继续推进",
                    "order_status", orderId, "order");
        }
    }

    @Override
    public List<DsOrderProgress> getProgressList(Long orderId) {
        return progressMapper.selectList(
                new LambdaQueryWrapper<DsOrderProgress>()
                        .eq(DsOrderProgress::getOrderId, orderId)
                        .orderByAsc(DsOrderProgress::getCreateTime));
    }

    @Override
    public void addProgress(Long orderId, OrderController.ProgressDTO dto) {
        DsOrder order = requireOrder(orderId);
        LoginUser loginUser = LoginHelper.getLoginUser();

        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(resolveProgressStepId(order));
        progress.setDescription(dto.getDescription());
        progress.setImageUrls(normalizeJsonField(dto.getImageUrls()));
        progress.setFormData(normalizeJsonField(dto.getFormData()));
        progress.setOperatorId(loginUser != null ? loginUser.getAdminId() : null);
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void payOrder(Long orderId, Long userId) {
        DsOrder order = requireOrder(orderId);
        if (!Objects.equals(order.getUserId(), userId)) {
            throw new RuntimeException("订单不存在或无权操作");
        }

        if (order.getStatus() == 0) {
            order.setStatus(1);
            order.setPaidAmount(order.getPrepayAmount());
            touchOrderForUpdate(order);
            updateOrderOrThrow(order);

            recordProgress(orderId, order.getCurrentStepId(), "客户已支付定金：¥" + order.getPrepayAmount(), null, null);

            // 扣减库存
            allocateOrderMaterials(orderId);

            notificationService.sendToUser(userId,
                    "定金支付成功",
                    "您已成功支付定金 ¥" + order.getPrepayAmount() + "，订单正式进入生产",
                    "payment", orderId, "order");
            return;
        }

        if (order.getStatus() == 6) {
            order.setStatus(2);
            order.setPaidAmount(order.getTotalAmount());
            touchOrderForUpdate(order);
            updateOrderOrThrow(order);

            recordProgress(orderId, order.getCurrentStepId(), "客户已支付尾款：¥"
                    + order.getTotalAmount().subtract(order.getPrepayAmount()), null, null);

            notificationService.sendToUser(userId,
                    "尾款支付成功",
                    "您已完成尾款支付，订单即将安排发货",
                    "payment", orderId, "order");
            return;
        }

        throw new RuntimeException("当前订单状态不需要支付");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void confirm(Long orderId, Long userId) {
        DsOrder order = requireOrder(orderId);
        if (!Objects.equals(order.getUserId(), userId)) {
            throw new RuntimeException("订单不存在或无权操作");
        }
        if (order.getStatus() == null || order.getStatus() != 3) {
            throw new RuntimeException("当前订单还不能确认收货");
        }

        order.setStatus(4);
        order.setConfirmTime(LocalDateTime.now());
        order.setFinishTime(LocalDateTime.now());
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);
        recordProgress(orderId, order.getCurrentStepId(), "客户已确认收货，订单已完成", null, null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancel(Long orderId, String cancelReason) {
        DsOrder order = requireOrder(orderId);
        if (Objects.equals(order.getStatus(), 4) || Objects.equals(order.getStatus(), 5)) {
            throw new RuntimeException("当前订单不能取消");
        }
        if (!StringUtils.hasText(cancelReason)) {
            throw new RuntimeException("请输入取消原因");
        }

        order.setStatus(5);
        order.setCancelReason(cancelReason);
        order.setIsBlocked(0);
        order.setBlockReason(null);
        order.setFinishTime(LocalDateTime.now());
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);
        recordProgress(orderId, order.getCurrentStepId(), "订单已取消：" + cancelReason, null, null);

        // 归还已扣减的库存
        releaseOrderMaterials(orderId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delay(Long orderId, OrderController.DelayDTO dto) {
        DsOrder order = requireOrder(orderId);
        if (Objects.equals(order.getStatus(), 4) || Objects.equals(order.getStatus(), 5)) {
            throw new RuntimeException("当前订单不能登记延期");
        }
        if (dto == null || !StringUtils.hasText(dto.getDelayReason())) {
            throw new RuntimeException("请输入延期原因");
        }
        if (dto.getExpectedDate() == null) {
            throw new RuntimeException("请选择新的预计交付时间");
        }

        order.setExpectedDate(dto.getExpectedDate());
        order.setDelayReason(dto.getDelayReason());
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);
        String description = StringUtils.hasText(dto.getDescription())
                ? dto.getDescription()
                : "订单延期至 " + dto.getExpectedDate() + "，原因：" + dto.getDelayReason();
        recordProgress(orderId, order.getCurrentStepId(), description, null, null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void ship(Long orderId, String description) {
        DsOrder order = requireOrder(orderId);
        if (!Objects.equals(order.getStatus(), 2)) {
            throw new RuntimeException("只有待发货订单才能执行发货");
        }

        order.setStatus(3);
        order.setDeliveryTime(LocalDateTime.now());
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);
        recordProgress(orderId, order.getCurrentStepId(),
                StringUtils.hasText(description) ? description : "订单已发货，等待客户确认收货",
                null,
                null);
    }

    @Override
    public List<DsOrder> getMyOrders(Long userId, Integer status) {
        LambdaQueryWrapper<DsOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DsOrder::getUserId, userId);
        if (status != null) {
            wrapper.eq(DsOrder::getStatus, status);
        }
        wrapper.orderByDesc(DsOrder::getCreateTime);
        List<DsOrder> orders = orderMapper.selectList(wrapper);
        fillOrderDisplayNames(orders);
        return orders;
    }

    @Override
    public OrderController.OrderDetailVO getAppOrderDetail(Long orderId, Long userId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null || !Objects.equals(order.getUserId(), userId)) {
            return null;
        }
        fillOrderDisplayName(order);

        OrderController.OrderDetailVO vo = new OrderController.OrderDetailVO();
        vo.setOrder(order);
        vo.setWorkflowSteps(getWorkflowStepsByCategory(order.getCategoryId()));
        vo.setProgressList(getProgressList(orderId));
        return vo;
    }

    @Override
    public WorkbenchController.WorkbenchVO getWorkbenchData(Long categoryId, Long stepId) {
        List<DsWorkflowStep> steps = getWorkflowStepsByCategory(categoryId);
        Long selectedStepId = stepId;
        if (selectedStepId == null && !steps.isEmpty()) {
            selectedStepId = resolveWorkbenchStepId(categoryId, steps);
        }

        LambdaQueryWrapper<DsOrder> wrapper = new LambdaQueryWrapper<DsOrder>()
                .eq(DsOrder::getCategoryId, categoryId)
                .in(DsOrder::getStatus, Arrays.asList(0, 1, 6))
                .orderByDesc(DsOrder::getCreateTime);
        if (selectedStepId != null) {
            wrapper.eq(DsOrder::getCurrentStepId, selectedStepId);
        }
        applyDesignerScope(wrapper);

        WorkbenchController.WorkbenchVO vo = new WorkbenchController.WorkbenchVO();
        vo.setCategoryId(categoryId);
        vo.setSelectedStepId(selectedStepId);
        vo.setWorkflowSteps(steps);
        List<DsOrder> orders = orderMapper.selectList(wrapper);
        fillOrderDisplayNames(orders);
        vo.setOrders(orders);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleWorkbenchAction(Long orderId, WorkbenchController.WorkbenchActionDTO dto) {
        DsOrder order = requireOrder(orderId);
        assertExpectedCurrentStep(order, dto != null ? dto.getExpectedCurrentStepId() : null);
        String action = dto.getAction();
        DsWorkflowStep currentStep = resolveCurrentStep(order);

        validateWorkbenchAction(action, dto, currentStep);

        if ("save".equals(action)) {
            OrderController.ProgressDTO progressDTO = new OrderController.ProgressDTO();
            progressDTO.setDescription(dto.getDescription());
            progressDTO.setImageUrls(dto.getImageUrls());
            progressDTO.setFormData(dto.getFormData());
            addProgress(orderId, progressDTO);
            return;
        }

        if ("advance".equals(action)) {
            OrderController.AdvanceDTO advanceDTO = new OrderController.AdvanceDTO();
            advanceDTO.setExpectedCurrentStepId(dto.getExpectedCurrentStepId());
            advanceDTO.setDescription(dto.getDescription());
            advanceDTO.setImageUrls(dto.getImageUrls());
            advanceDTO.setFormData(dto.getFormData());
            advance(orderId, advanceDTO);
            return;
        }

        if ("rollback".equals(action)) {
            rollback(order, dto);
            return;
        }

        if ("block".equals(action)) {
            block(orderId, dto.getBlockReason());
            recordProgress(orderId, order.getCurrentStepId(),
                    StringUtils.hasText(dto.getDescription())
                            ? dto.getDescription()
                            : "订单已阻塞：" + dto.getBlockReason(),
                    dto.getImageUrls(),
                    dto.getFormData());
            return;
        }

        if ("unblock".equals(action)) {
            unblock(orderId);
            recordProgress(orderId, order.getCurrentStepId(),
                    StringUtils.hasText(dto.getDescription())
                            ? dto.getDescription()
                            : "订单已解除阻塞",
                    dto.getImageUrls(),
                    dto.getFormData());
            return;
        }

        throw new RuntimeException("不支持的工作台动作");
    }

    @Override
    public AppOrderController.OrderTimelineVO getOrderTimeline(Long orderId, Long userId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null || !Objects.equals(order.getUserId(), userId)) {
            return null;
        }
        fillOrderDisplayName(order);

        List<DsWorkflowStep> allSteps = getWorkflowStepsByCategory(order.getCategoryId()).stream()
                .filter(step -> step.getVisibleToClient() == null || step.getVisibleToClient() == 1)
                .collect(Collectors.toList());
        Set<Long> visibleStepIds = allSteps.stream()
                .map(DsWorkflowStep::getStepId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        List<DsOrderProgress> progressList = getProgressList(orderId).stream()
                .filter(progress -> progress.getStepId() == null || visibleStepIds.contains(progress.getStepId()))
                .collect(Collectors.toList());
        Map<String, DsCustomField> categoryFieldMap = buildCategoryFieldMap(order.getCategoryId());

        // 构建操作者名称映射
        Map<Long, String> operatorNameMap = buildOperatorNameMap(progressList);

        AppOrderController.OrderTimelineVO vo = new AppOrderController.OrderTimelineVO();
        vo.setOrder(order);
        vo.setWorkflowSteps(allSteps);
        vo.setProgressList(progressList);

        int currentStepIndex = resolveTimelineStepIndex(allSteps, order.getCurrentStepId(), progressList);
        vo.setCurrentStepIndex(currentStepIndex);
        vo.setCurrentStepName(currentStepIndex >= 0 && currentStepIndex < allSteps.size()
                ? allSteps.get(currentStepIndex).getStepName()
                : null);

        List<AppOrderController.TimelineEventVO> timelineEvents = buildTimelineEvents(allSteps, progressList, categoryFieldMap, operatorNameMap);
        vo.setTimelineEvents(timelineEvents);
        vo.setHasRollback(timelineEvents.stream().anyMatch(event -> "rollback".equals(event.getEventType())) ? 1 : 0);
        vo.setCurrentStepFormEntries(resolveCurrentStepFormEntries(order.getCurrentStepId(), progressList, categoryFieldMap));

        // 逾期计算
        resolveOverdueInfo(vo, order);

        // 当前步骤耗时
        resolveCurrentStepElapsed(vo, allSteps, progressList, currentStepIndex);

        return vo;
    }

    private DsOrder requireOrder(Long orderId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        ensureDesignerCanAccess(order);
        return order;
    }

    private void applyDesignerScope(LambdaQueryWrapper<DsOrder> wrapper) {
        Long designerId = getCurrentDesignerId();
        if (designerId != null) {
            wrapper.eq(DsOrder::getDesignerId, designerId);
        }
    }

    private void ensureDesignerCanAccess(DsOrder order) {
        Long designerId = getCurrentDesignerId();
        if (designerId != null && !Objects.equals(order.getDesignerId(), designerId)) {
            throw new RuntimeException("无权访问其他设计师负责的订单");
        }
    }

    private Long getCurrentDesignerId() {
        LoginUser loginUser = LoginHelper.getLoginUser();
        if (loginUser == null || loginUser.getAdminId() == null) {
            return null;
        }
        List<String> roleKeys = loginUser.getRoleKeys();
        if (roleKeys == null || roleKeys.isEmpty()) {
            return null;
        }
        boolean isAdmin = roleKeys.stream().anyMatch(role -> "admin".equalsIgnoreCase(role));
        boolean isDesigner = roleKeys.stream().anyMatch(role -> "designer".equalsIgnoreCase(role));
        if (isDesigner && !isAdmin) {
            return loginUser.getAdminId();
        }
        return null;
    }

    private void fillOrderDisplayName(DsOrder order) {
        fillOrderDisplayNames(order);
    }

    private void fillOrderDisplayNames(DsOrder order) {
        if (order == null) {
            return;
        }
        fillOrderDisplayNames(Collections.singletonList(order));
    }

    private void fillOrderDisplayNames(List<DsOrder> orders) {
        if (orders == null || orders.isEmpty()) {
            return;
        }

        Set<Long> userIds = orders.stream()
                .map(DsOrder::getUserId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Set<Long> adminIds = orders.stream()
                .map(DsOrder::getDesignerId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        Map<Long, String> userNameMap = userIds.isEmpty()
                ? Collections.emptyMap()
                : userMapper.selectBatchIds(userIds).stream().collect(Collectors.toMap(
                        DsUser::getUserId,
                        user -> StringUtils.hasText(user.getNickname())
                                ? user.getNickname()
                                : "客户#" + user.getUserId(),
                        (left, right) -> left));

        Map<Long, String> adminNameMap = adminIds.isEmpty()
                ? Collections.emptyMap()
                : adminMapper.selectBatchIds(adminIds).stream().collect(Collectors.toMap(
                        SysAdmin::getAdminId,
                        admin -> StringUtils.hasText(admin.getNickname())
                                ? admin.getNickname()
                                : (StringUtils.hasText(admin.getUsername())
                                ? admin.getUsername()
                                : "设计师#" + admin.getAdminId()),
                        (left, right) -> left));

        for (DsOrder order : orders) {
            if (order.getUserId() != null) {
                order.setCustomerName(userNameMap.getOrDefault(order.getUserId(), "客户#" + order.getUserId()));
            }
            if (order.getDesignerId() != null) {
                order.setDesignerName(adminNameMap.getOrDefault(order.getDesignerId(), "设计师#" + order.getDesignerId()));
            }
        }
    }

    private List<DsWorkflowStep> requireWorkflowSteps(Long categoryId) {
        List<DsWorkflowStep> steps = getWorkflowStepsByCategory(categoryId);
        if (steps.isEmpty()) {
            throw new RuntimeException("当前品类未配置工作流");
        }
        return steps;
    }

    private DsWorkflowStep resolveNextStep(List<DsWorkflowStep> steps, Long currentStepId) {
        if (currentStepId == null) {
            return steps.get(0);
        }
        for (int i = 0; i < steps.size(); i++) {
            if (Objects.equals(steps.get(i).getStepId(), currentStepId)) {
                return i + 1 < steps.size() ? steps.get(i + 1) : null;
            }
        }
        return null;
    }

    private void finishOrder(DsOrder order, OrderController.AdvanceDTO dto) {
        boolean needsBalancePayment = order.getTotalAmount() != null
                && order.getPrepayAmount() != null
                && order.getTotalAmount().compareTo(order.getPrepayAmount()) > 0;
        String progressDescription;
        if (needsBalancePayment) {
            order.setStatus(6);
            progressDescription = "生产完毕，等待客户支付尾款";
        } else {
            order.setStatus(2);
            progressDescription = "生产完毕，等待发货";
        }
        order.setFinishTime(LocalDateTime.now());
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(order.getOrderId());
        progress.setStepId(resolveProgressStepId(order));
        progress.setDescription(StringUtils.hasText(dto.getDescription()) ? dto.getDescription() : progressDescription);
        progress.setImageUrls(normalizeJsonField(dto.getImageUrls()));
        progress.setFormData(normalizeJsonField(dto.getFormData()));
        LoginUser loginUser = LoginHelper.getLoginUser();
        progress.setOperatorId(loginUser != null ? loginUser.getAdminId() : null);
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);

        if (order.getUserId() != null) {
            String notifyContent = needsBalancePayment
                    ? "您的订单已生产完毕，请前往支付尾款"
                    : "您的订单已生产完毕，即将安排发货，请注意查收";
            notificationService.sendToUser(order.getUserId(),
                    "生产完毕通知",
                    notifyContent,
                    "order_status", order.getOrderId(), "order");
        }
    }

    private Long resolveProgressStepId(DsOrder order) {
        if (order.getCurrentStepId() != null) {
            return order.getCurrentStepId();
        }
        DsWorkflowStep currentStep = resolveCurrentStep(order);
        if (currentStep != null) {
            return currentStep.getStepId();
        }
        throw new RuntimeException("当前订单未绑定工作流节点，无法记录进度");
    }

    private Long resolveWorkbenchStepId(Long categoryId, List<DsWorkflowStep> steps) {
        List<DsOrder> activeOrders = orderMapper.selectList(
                new LambdaQueryWrapper<DsOrder>()
                        .eq(DsOrder::getCategoryId, categoryId)
                        .in(DsOrder::getStatus, Arrays.asList(0, 1, 6))
                        .isNotNull(DsOrder::getCurrentStepId)
                        .orderByDesc(DsOrder::getCreateTime));
        Set<Long> activeStepIds = activeOrders.stream()
                .map(DsOrder::getCurrentStepId)
                .collect(Collectors.toSet());
        for (DsWorkflowStep step : steps) {
            if (activeStepIds.contains(step.getStepId())) {
                return step.getStepId();
            }
        }
        return steps.get(0).getStepId();
    }

    private List<DsWorkflowStep> getWorkflowStepsByCategory(Long categoryId) {
        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>().eq(DsWorkflow::getCategoryId, categoryId));
        if (workflow == null) {
            return Collections.emptyList();
        }
        return stepMapper.selectList(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId())
                        .orderByAsc(DsWorkflowStep::getStepOrder));
    }

    private int findCurrentStepIndex(List<DsWorkflowStep> steps, Long currentStepId) {
        if (currentStepId == null) {
            return -1;
        }
        for (int i = 0; i < steps.size(); i++) {
            if (Objects.equals(steps.get(i).getStepId(), currentStepId)) {
                return i;
            }
        }
        return -1;
    }

    private int resolveTimelineStepIndex(List<DsWorkflowStep> steps, Long currentStepId,
                                         List<DsOrderProgress> progressList) {
        int currentIndex = findCurrentStepIndex(steps, currentStepId);
        if (currentIndex >= 0) {
            return currentIndex;
        }
        if (progressList == null || progressList.isEmpty()) {
            return -1;
        }
        for (int i = progressList.size() - 1; i >= 0; i--) {
            int progressIndex = findCurrentStepIndex(steps, progressList.get(i).getStepId());
            if (progressIndex >= 0) {
                return progressIndex;
            }
        }
        return -1;
    }

    private List<AppOrderController.TimelineEventVO> buildTimelineEvents(List<DsWorkflowStep> steps,
                                                                         List<DsOrderProgress> progressList,
                                                                         Map<String, DsCustomField> categoryFieldMap,
                                                                         Map<Long, String> operatorNameMap) {
        if (progressList == null || progressList.isEmpty()) {
            return Collections.emptyList();
        }

        List<AppOrderController.TimelineEventVO> events = new ArrayList<>();
        int lastStepIndex = -1;
        for (DsOrderProgress progress : progressList) {
            int currentIndex = findCurrentStepIndex(steps, progress.getStepId());
            String eventType = resolveTimelineEventTypeV2(progress, currentIndex, lastStepIndex);

            AppOrderController.TimelineEventVO event = new AppOrderController.TimelineEventVO();
            event.setProgressId(progress.getProgressId());
            event.setStepId(progress.getStepId());
            event.setStepName(resolveStepNameForTimeline(steps, progress));
            event.setDescription(progress.getDescription());
            event.setImageUrls(progress.getImageUrls());
            event.setCreateTime(progress.getCreateTime());
            event.setEventType(eventType);
            event.setEventLabel(resolveTimelineEventLabelV2(eventType));
            event.setFormEntries(buildFormEntries(progress.getFormData(), categoryFieldMap));
            event.setOperatorName(operatorNameMap.getOrDefault(progress.getOperatorId(), null));
            events.add(event);

            if (currentIndex >= 0) {
                lastStepIndex = currentIndex;
            }
        }
        return events;
    }

    private String resolveTimelineEventType(DsOrderProgress progress, int currentIndex, int lastStepIndex) {
        String description = progress.getDescription() == null ? "" : progress.getDescription();
        if (description.contains("解除阻塞")) {
            return "unblock";
        }
        if (description.contains("阻塞")) {
            return "block";
        }
        if (description.contains("退回")) {
            return "rollback";
        }
        if (description.contains("支付")) {
            return "payment";
        }
        if (currentIndex >= 0 && lastStepIndex >= 0 && currentIndex < lastStepIndex) {
            return "rollback";
        }
        return "progress";
    }

    private String resolveTimelineEventLabel(String eventType) {
        switch (eventType) {
            case "rollback":
                return "返工";
            case "block":
                return "阻塞";
            case "unblock":
                return "恢复";
            case "payment":
                return "支付";
            default:
                return "进度";
        }
    }

    private String resolveTimelineEventTypeV2(DsOrderProgress progress, int currentIndex, int lastStepIndex) {
        String description = progress.getDescription() == null ? "" : progress.getDescription();
        if (description.contains("解除阻塞")) {
            return "unblock";
        }
        if (description.contains("阻塞")) {
            return "block";
        }
        if (description.contains("已取消")) {
            return "cancel";
        }
        if (description.contains("延期")) {
            return "delay";
        }
        if (description.contains("已发货")) {
            return "shipment";
        }
        if (description.contains("确认收货") || description.contains("订单已完成")) {
            return "confirm";
        }
        if (description.contains("退回")) {
            return "rollback";
        }
        if (description.contains("支付")) {
            return "payment";
        }
        if (currentIndex >= 0 && lastStepIndex >= 0 && currentIndex < lastStepIndex) {
            return "rollback";
        }
        return "progress";
    }

    private String resolveTimelineEventLabelV2(String eventType) {
        switch (eventType) {
            case "rollback":
                return "返工";
            case "block":
                return "阻塞";
            case "unblock":
                return "恢复";
            case "cancel":
                return "取消";
            case "delay":
                return "延期";
            case "shipment":
                return "发货";
            case "confirm":
                return "完成";
            case "payment":
                return "支付";
            default:
                return "进度";
        }
    }

    private String resolveStepName(List<DsWorkflowStep> steps, Long stepId) {
        if (stepId == null) {
            return "未绑定节点";
        }
        return steps.stream()
                .filter(step -> Objects.equals(step.getStepId(), stepId))
                .map(DsWorkflowStep::getStepName)
                .findFirst()
                .orElse("节点 #" + stepId);
    }

    /** 时间线专用：对支付等无 stepId 的记录返回友好名称 */
    private String resolveStepNameForTimeline(List<DsWorkflowStep> steps, DsOrderProgress progress) {
        if (progress.getStepId() != null) {
            return resolveStepName(steps, progress.getStepId());
        }
        String desc = progress.getDescription() == null ? "" : progress.getDescription();
        if (desc.contains("支付")) {
            return "支付确认";
        }
        return "系统操作";
    }

    /** 构建操作者 ID → 名称映射 */
    private Map<Long, String> buildOperatorNameMap(List<DsOrderProgress> progressList) {
        if (progressList == null || progressList.isEmpty()) {
            return Collections.emptyMap();
        }
        Set<Long> operatorIds = progressList.stream()
                .map(DsOrderProgress::getOperatorId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (operatorIds.isEmpty()) {
            return Collections.emptyMap();
        }
        return adminMapper.selectBatchIds(operatorIds).stream()
                .collect(Collectors.toMap(
                        SysAdmin::getAdminId,
                        admin -> StringUtils.hasText(admin.getNickname())
                                ? admin.getNickname()
                                : (StringUtils.hasText(admin.getUsername()) ? admin.getUsername() : "设计师#" + admin.getAdminId()),
                        (left, right) -> left));
    }

    /** 计算逾期信息 */
    private void resolveOverdueInfo(AppOrderController.OrderTimelineVO vo, DsOrder order) {
        if (order.getExpectedDate() == null || order.getStatus() == null
                || order.getStatus() >= 4 || order.getStatus() == 5) {
            vo.setIsOverdue(false);
            vo.setOverdueDays(0);
            return;
        }
        LocalDate today = LocalDate.now();
        long daysDiff = ChronoUnit.DAYS.between(today, order.getExpectedDate());
        boolean isOverdue = daysDiff < 0;
        vo.setIsOverdue(isOverdue);
        vo.setOverdueDays(isOverdue ? (int) Math.abs(daysDiff) : 0);
        if (daysDiff > 0) {
            vo.setExpectedDateText("还剩" + daysDiff + "天");
        } else if (daysDiff == 0) {
            vo.setExpectedDateText("今天截止");
        } else {
            vo.setExpectedDateText("逾期" + Math.abs(daysDiff) + "天");
        }
    }

    /** 计算当前步骤已耗时 */
    private void resolveCurrentStepElapsed(AppOrderController.OrderTimelineVO vo,
                                           List<DsWorkflowStep> steps,
                                           List<DsOrderProgress> progressList,
                                           int currentStepIndex) {
        if (currentStepIndex < 0 || currentStepIndex >= steps.size() || progressList.isEmpty()) {
            return;
        }
        Long currentStepId = steps.get(currentStepIndex).getStepId();
        // 找到进入当前步骤的第一条进度记录
        LocalDateTime enterTime = null;
        for (DsOrderProgress p : progressList) {
            if (Objects.equals(p.getStepId(), currentStepId)) {
                enterTime = p.getCreateTime();
                break;
            }
        }
        if (enterTime == null) {
            return;
        }
        long elapsedDays = ChronoUnit.DAYS.between(enterTime.toLocalDate(), LocalDate.now());
        vo.setCurrentStepElapsedDays((int) elapsedDays);
        DsWorkflowStep currentStep = steps.get(currentStepIndex);
        vo.setCurrentStepExpectedDays(currentStep.getExpectedDurationDays());
    }

    private Map<String, DsCustomField> buildCategoryFieldMap(Long categoryId) {
        if (categoryId == null) {
            return Collections.emptyMap();
        }
        return customFieldMapper.selectList(new LambdaQueryWrapper<DsCustomField>()
                        .eq(DsCustomField::getCategoryId, categoryId)
                        .orderByAsc(DsCustomField::getSortOrder)
                        .orderByAsc(DsCustomField::getFieldId))
                .stream()
                .filter(field -> StringUtils.hasText(field.getFieldKey()))
                .collect(Collectors.toMap(
                        DsCustomField::getFieldKey,
                        field -> field,
                        (left, right) -> left,
                        LinkedHashMap::new));
    }

    private List<AppOrderController.FormEntryVO> resolveCurrentStepFormEntries(Long currentStepId,
                                                                               List<DsOrderProgress> progressList,
                                                                               Map<String, DsCustomField> categoryFieldMap) {
        if (currentStepId == null || progressList == null || progressList.isEmpty()) {
            return Collections.emptyList();
        }
        for (int index = progressList.size() - 1; index >= 0; index--) {
            DsOrderProgress progress = progressList.get(index);
            if (!Objects.equals(progress.getStepId(), currentStepId)) {
                continue;
            }
            List<AppOrderController.FormEntryVO> entries = buildFormEntries(progress.getFormData(), categoryFieldMap);
            if (!entries.isEmpty()) {
                return entries;
            }
        }
        return Collections.emptyList();
    }

    private List<AppOrderController.FormEntryVO> buildFormEntries(String formData,
                                                                  Map<String, DsCustomField> categoryFieldMap) {
        Map<String, Object> valueMap = parseFormDataMap(formData);
        if (valueMap.isEmpty()) {
            return Collections.emptyList();
        }

        List<AppOrderController.FormEntryVO> entries = new ArrayList<>();
        for (Map.Entry<String, Object> entry : valueMap.entrySet()) {
            String valueText = formatFormValue(entry.getValue());
            if (!StringUtils.hasText(valueText)) {
                continue;
            }
            DsCustomField field = categoryFieldMap.get(entry.getKey());
            AppOrderController.FormEntryVO formEntry = new AppOrderController.FormEntryVO();
            formEntry.setKey(entry.getKey());
            formEntry.setLabel(field != null && StringUtils.hasText(field.getLabel()) ? field.getLabel() : entry.getKey());
            formEntry.setUnit(field != null ? field.getUnit() : null);
            formEntry.setValue(valueText);
            entries.add(formEntry);
        }
        return entries;
    }

    private String formatFormValue(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Collection<?>) {
            return ((Collection<?>) value).stream()
                    .filter(Objects::nonNull)
                    .map(String::valueOf)
                    .filter(StringUtils::hasText)
                    .collect(Collectors.joining("、"));
        }
        if (value.getClass().isArray()) {
            int length = java.lang.reflect.Array.getLength(value);
            List<String> values = new ArrayList<>(length);
            for (int index = 0; index < length; index++) {
                Object item = java.lang.reflect.Array.get(value, index);
                if (item != null && StringUtils.hasText(String.valueOf(item))) {
                    values.add(String.valueOf(item));
                }
            }
            return String.join("、", values);
        }
        return String.valueOf(value);
    }

    private void recordProgress(Long orderId, Long stepId, String description, String imageUrls, String formData) {
        LoginUser loginUser = LoginHelper.getLoginUser();
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(stepId);
        progress.setDescription(description);
        progress.setImageUrls(normalizeJsonField(imageUrls));
        progress.setFormData(normalizeJsonField(formData));
        progress.setOperatorId(loginUser != null ? loginUser.getAdminId() : null);
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);
    }

    private void touchOrderForUpdate(DsOrder order) {
        LoginUser loginUser = LoginHelper.getLoginUser();
        order.setUpdateTime(LocalDateTime.now());
        order.setUpdateBy(loginUser != null ? loginUser.getAdminId() : null);
    }

    private void assertExpectedCurrentStep(DsOrder order, Long expectedCurrentStepId) {
        if (!Objects.equals(order.getCurrentStepId(), expectedCurrentStepId)) {
            throw new RuntimeException("订单节点已变化，请刷新后重试");
        }
    }

    private void updateOrderOrThrow(DsOrder order) {
        if (orderMapper.updateById(order) != 1) {
            throw new RuntimeException("订单状态已变化，请刷新后重试");
        }
    }

    private void rollback(DsOrder order, WorkbenchController.WorkbenchActionDTO dto) {
        if (order.getIsBlocked() != null && order.getIsBlocked() == 1) {
            throw new RuntimeException("订单已阻塞，请先解除阻塞后再退回");
        }

        List<DsWorkflowStep> steps = requireWorkflowSteps(order.getCategoryId());
        int currentIndex = findCurrentStepIndex(steps, order.getCurrentStepId());
        if (currentIndex <= 0) {
            throw new RuntimeException("当前订单已经在首个节点，无法继续退回");
        }

        DsWorkflowStep targetStep = resolveRollbackTargetStep(steps, currentIndex, dto.getRollbackTargetStepId());
        order.setCurrentStepId(targetStep.getStepId());
        if (order.getStatus() != null && order.getStatus() != 1) {
            order.setStatus(1);
        }
        order.setFinishTime(null);
        touchOrderForUpdate(order);
        updateOrderOrThrow(order);

        String description = StringUtils.hasText(dto.getDescription())
                ? dto.getDescription()
                : "退回至节点：" + targetStep.getStepName();
        recordProgress(order.getOrderId(), targetStep.getStepId(), description, dto.getImageUrls(), dto.getFormData());
    }

    private DsWorkflowStep resolveRollbackTargetStep(List<DsWorkflowStep> steps, int currentIndex,
                                                     Long rollbackTargetStepId) {
        if (rollbackTargetStepId == null) {
            return steps.get(currentIndex - 1);
        }
        for (int i = 0; i < currentIndex; i++) {
            DsWorkflowStep step = steps.get(i);
            if (Objects.equals(step.getStepId(), rollbackTargetStepId)) {
                return step;
            }
        }
        throw new RuntimeException("只能退回到当前节点之前的前序节点");
    }

    private DsWorkflowStep resolveCurrentStep(DsOrder order) {
        List<DsWorkflowStep> steps = getWorkflowStepsByCategory(order.getCategoryId());
        if (steps.isEmpty()) {
            return null;
        }
        if (order.getCurrentStepId() == null) {
            return steps.get(0);
        }
        return steps.stream()
                .filter(step -> Objects.equals(step.getStepId(), order.getCurrentStepId()))
                .findFirst()
                .orElse(null);
    }

    private void validateWorkbenchAction(String action, WorkbenchController.WorkbenchActionDTO dto,
                                         DsWorkflowStep currentStep) {
        if (!StringUtils.hasText(action)) {
            throw new RuntimeException("工作台动作不能为空");
        }

        Set<String> allowedActions = parseAllowedActions(currentStep);
        if (!allowedActions.contains(action)) {
            throw new RuntimeException("当前节点不允许执行该动作");
        }

        if ("block".equals(action) && !StringUtils.hasText(dto.getBlockReason())) {
            throw new RuntimeException("请输入阻塞原因");
        }

        if ("rollback".equals(action) && dto.getRollbackTargetStepId() != null && currentStep == null) {
            throw new RuntimeException("当前节点不存在，无法退回");
        }

        if (currentStep != null && ("save".equals(action) || "advance".equals(action))) {
            validateNodeFormData(currentStep, dto.getFormData());
        }

        if (currentStep != null
                && currentStep.getNeedImageUpload() != null
                && currentStep.getNeedImageUpload() == 1
                && ("save".equals(action) || "advance".equals(action))
                && !StringUtils.hasText(dto.getImageUrls())) {
            throw new RuntimeException("当前节点要求上传图片");
        }
    }

    private Set<String> parseAllowedActions(DsWorkflowStep currentStep) {
        if (currentStep == null || !StringUtils.hasText(currentStep.getAllowedActions())) {
            return new HashSet<>(Arrays.asList("save", "advance", "rollback", "block", "unblock"));
        }
        try {
            List<String> actions = objectMapper.readValue(
                    currentStep.getAllowedActions(),
                    new TypeReference<List<String>>() {});
            return new HashSet<>(actions);
        } catch (Exception ignored) {
            return new HashSet<>(Arrays.asList("save", "advance", "rollback", "block", "unblock"));
        }
    }

    private void validateNodeFormData(DsWorkflowStep currentStep, String formData) {
        List<String> fieldKeys = parseNodeFormFieldKeys(currentStep);
        if (fieldKeys.isEmpty()) {
            return;
        }

        Long categoryId = resolveCategoryIdByWorkflowId(currentStep.getWorkflowId());
        if (categoryId == null) {
            return;
        }
        List<DsCustomField> fields = customFieldMapper.selectList(new LambdaQueryWrapper<DsCustomField>()
                .eq(DsCustomField::getCategoryId, categoryId)
                .in(DsCustomField::getFieldKey, fieldKeys));
        Map<String, Object> formValueMap = parseFormDataMap(formData);
        if (formValueMap.isEmpty()) {
            boolean hasRequiredFields = fields.stream().anyMatch(field -> field.getIsRequired() != null && field.getIsRequired() == 1);
            if (hasRequiredFields) {
                throw new RuntimeException("请填写当前节点的必填字段");
            }
            return;
        }
        for (DsCustomField field : fields) {
            if (field.getIsRequired() != null && field.getIsRequired() == 1) {
                Object value = formValueMap.get(field.getFieldKey());
                if (value == null || !StringUtils.hasText(String.valueOf(value))) {
                    throw new RuntimeException("请填写节点字段：" + field.getLabel());
                }
            }
        }
    }

    private List<String> parseNodeFormFieldKeys(DsWorkflowStep currentStep) {
        if (currentStep == null || !StringUtils.hasText(currentStep.getNodeFormFields())) {
            return Collections.emptyList();
        }
        try {
            return objectMapper.readValue(currentStep.getNodeFormFields(), new TypeReference<List<String>>() {});
        } catch (Exception ignored) {
            return Collections.emptyList();
        }
    }

    private Map<String, Object> parseFormDataMap(String formData) {
        if (!StringUtils.hasText(formData)) {
            return Collections.emptyMap();
        }
        try {
            return objectMapper.readValue(formData, new TypeReference<Map<String, Object>>() {});
        } catch (Exception ignored) {
            return Collections.emptyMap();
        }
    }

    private Long resolveCategoryIdByWorkflowId(Long workflowId) {
        if (workflowId == null) {
            return null;
        }
        DsWorkflow workflow = workflowMapper.selectById(workflowId);
        return workflow != null ? workflow.getCategoryId() : null;
    }

    private String normalizeJsonField(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    @Override
    public List<DsBomItem> getOrderBom(Long orderId) {
        return bomItemMapper.selectList(
                new LambdaQueryWrapper<DsBomItem>()
                        .eq(DsBomItem::getOrderId, orderId));
    }

    /** 扣减订单 BOM 物料库存 */
    private void allocateOrderMaterials(Long orderId) {
        List<DsBomItem> bomItems = bomItemMapper.selectList(
                new LambdaQueryWrapper<DsBomItem>()
                        .eq(DsBomItem::getOrderId, orderId)
                        .eq(DsBomItem::getIsAllocated, 0));
        if (bomItems.isEmpty()) return;

        for (DsBomItem item : bomItems) {
            DsMaterial material = materialMapper.selectById(item.getMaterialId());
            if (material == null) {
                throw new RuntimeException("物料不存在，ID：" + item.getMaterialId());
            }
            if (material.getStock().compareTo(item.getQuantity()) < 0) {
                throw new RuntimeException("物料「" + material.getName() + "」库存不足，当前库存：" + material.getStock() + " " + material.getUnit());
            }
        }

        for (DsBomItem item : bomItems) {
            DsMaterial material = materialMapper.selectById(item.getMaterialId());
            material.setStock(material.getStock().subtract(item.getQuantity()));
            updateMaterialOrThrow(material);

            item.setIsAllocated(1);
            bomItemMapper.updateById(item);
        }
    }

    /** 归还已扣减的订单 BOM 物料库存 */
    private void releaseOrderMaterials(Long orderId) {
        List<DsBomItem> bomItems = bomItemMapper.selectList(
                new LambdaQueryWrapper<DsBomItem>()
                        .eq(DsBomItem::getOrderId, orderId)
                        .eq(DsBomItem::getIsAllocated, 1));
        if (bomItems.isEmpty()) return;

        for (DsBomItem item : bomItems) {
            DsMaterial material = materialMapper.selectById(item.getMaterialId());
            if (material != null) {
                material.setStock(material.getStock().add(item.getQuantity()));
                updateMaterialOrThrow(material);
            }
            item.setIsAllocated(0);
            bomItemMapper.updateById(item);
        }
    }

    private void updateMaterialOrThrow(DsMaterial material) {
        if (materialMapper.updateById(material) != 1) {
            throw new RuntimeException("物料库存已变化，请刷新后重试");
        }
    }
}
