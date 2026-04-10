package com.designstudio.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.common.security.LoginUser;
import com.designstudio.config.domain.DsWorkflow;
import com.designstudio.config.domain.DsWorkflowStep;
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
import com.designstudio.system.domain.SysAdmin;
import com.designstudio.system.mapper.SysAdminMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final DsOrderMapper orderMapper;
    private final DsOrderProgressMapper progressMapper;
    private final DsWorkflowMapper workflowMapper;
    private final DsWorkflowStepMapper stepMapper;
    private final DsUserMapper userMapper;
    private final SysAdminMapper adminMapper;
    private final ObjectMapper objectMapper;

    @Override
    public List<DsOrder> listOrders(Integer status, Long categoryId, Long designerId) {
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
        List<DsOrder> orders = orderMapper.selectList(wrapper);
        fillOrderDisplayNames(orders);
        return orders;
    }

    @Override
    public OrderController.OrderDetailVO getOrderDetail(Long orderId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) {
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
    public List<OrderController.KanbanColumnVO> getKanbanData(Long categoryId) {
        LambdaQueryWrapper<DsOrder> orderWrapper = new LambdaQueryWrapper<DsOrder>()
                .eq(DsOrder::getStatus, 1);
        if (categoryId != null) {
            orderWrapper.eq(DsOrder::getCategoryId, categoryId);
        }
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
        if (order.getStatus() != 1) {
            throw new RuntimeException("只有生产中的订单才能推进");
        }
        if (order.getIsBlocked() != null && order.getIsBlocked() == 1) {
            throw new RuntimeException("订单已阻塞，请先解除阻塞");
        }

        List<DsWorkflowStep> steps = requireWorkflowSteps(order.getCategoryId());
        DsWorkflowStep nextStep = resolveNextStep(steps, order.getCurrentStepId());
        if (nextStep == null) {
            finishOrder(order);
            return;
        }

        order.setCurrentStepId(nextStep.getStepId());
        touchOrderForUpdate(order);
        orderMapper.updateById(order);

        LoginUser loginUser = LoginHelper.getLoginUser();
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(nextStep.getStepId());
        progress.setDescription(StringUtils.hasText(dto.getDescription())
                ? dto.getDescription()
                : "推进至节点：" + nextStep.getStepName());
        progress.setImageUrls(normalizeJsonField(dto.getImageUrls()));
        progress.setOperatorId(loginUser != null ? loginUser.getAdminId() : null);
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);
    }

    @Override
    public void block(Long orderId, String blockReason) {
        DsOrder order = requireOrder(orderId);
        order.setIsBlocked(1);
        order.setBlockReason(blockReason);
        touchOrderForUpdate(order);
        orderMapper.updateById(order);
    }

    @Override
    public void unblock(Long orderId) {
        DsOrder order = requireOrder(orderId);
        order.setIsBlocked(0);
        order.setBlockReason(null);
        touchOrderForUpdate(order);
        orderMapper.updateById(order);
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
        progress.setStepId(order.getCurrentStepId());
        progress.setDescription(dto.getDescription());
        progress.setImageUrls(normalizeJsonField(dto.getImageUrls()));
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
            orderMapper.updateById(order);

            DsOrderProgress progress = new DsOrderProgress();
            progress.setOrderId(orderId);
            progress.setDescription("客户已支付定金：¥" + order.getPrepayAmount());
            progressMapper.insert(progress);
            return;
        }

        if (order.getStatus() == 6) {
            order.setStatus(2);
            order.setPaidAmount(order.getTotalAmount());
            touchOrderForUpdate(order);
            orderMapper.updateById(order);

            DsOrderProgress progress = new DsOrderProgress();
            progress.setOrderId(orderId);
            progress.setDescription("客户已支付尾款：¥"
                    + order.getTotalAmount().subtract(order.getPrepayAmount()));
            progressMapper.insert(progress);
            return;
        }

        throw new RuntimeException("当前订单状态不需要支付");
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
        String action = dto.getAction();
        DsWorkflowStep currentStep = resolveCurrentStep(order);

        validateWorkbenchAction(action, dto, currentStep);

        if ("save".equals(action)) {
            OrderController.ProgressDTO progressDTO = new OrderController.ProgressDTO();
            progressDTO.setDescription(dto.getDescription());
            progressDTO.setImageUrls(dto.getImageUrls());
            addProgress(orderId, progressDTO);
            return;
        }

        if ("advance".equals(action)) {
            OrderController.AdvanceDTO advanceDTO = new OrderController.AdvanceDTO();
            advanceDTO.setDescription(dto.getDescription());
            advanceDTO.setImageUrls(dto.getImageUrls());
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
                    dto.getImageUrls());
            return;
        }

        if ("unblock".equals(action)) {
            unblock(orderId);
            recordProgress(orderId, order.getCurrentStepId(),
                    StringUtils.hasText(dto.getDescription())
                            ? dto.getDescription()
                            : "订单已解除阻塞",
                    dto.getImageUrls());
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
        List<DsOrderProgress> progressList = getProgressList(orderId);

        AppOrderController.OrderTimelineVO vo = new AppOrderController.OrderTimelineVO();
        vo.setOrder(order);
        vo.setWorkflowSteps(allSteps);
        vo.setProgressList(progressList);

        int currentStepIndex = resolveTimelineStepIndex(allSteps, order.getCurrentStepId(), progressList);
        vo.setCurrentStepIndex(currentStepIndex);
        vo.setCurrentStepName(currentStepIndex >= 0 && currentStepIndex < allSteps.size()
                ? allSteps.get(currentStepIndex).getStepName()
                : null);

        List<AppOrderController.TimelineEventVO> timelineEvents = buildTimelineEvents(allSteps, progressList);
        vo.setTimelineEvents(timelineEvents);
        vo.setHasRollback(timelineEvents.stream().anyMatch(event -> "rollback".equals(event.getEventType())) ? 1 : 0);
        return vo;
    }

    private DsOrder requireOrder(Long orderId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        return order;
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

    private void finishOrder(DsOrder order) {
        if (order.getTotalAmount() != null
                && order.getPrepayAmount() != null
                && order.getTotalAmount().compareTo(order.getPrepayAmount()) > 0) {
            order.setStatus(6);
            LoginUser loginUser = LoginHelper.getLoginUser();
            DsOrderProgress progress = new DsOrderProgress();
            progress.setOrderId(order.getOrderId());
            progress.setDescription("生产完毕，等待客户支付尾款");
            progress.setOperatorId(loginUser != null ? loginUser.getAdminId() : null);
            progress.setCreateTime(LocalDateTime.now());
            progressMapper.insert(progress);
        } else {
            order.setStatus(2);
        }
        order.setFinishTime(LocalDateTime.now());
        touchOrderForUpdate(order);
        orderMapper.updateById(order);
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
                                                                         List<DsOrderProgress> progressList) {
        if (progressList == null || progressList.isEmpty()) {
            return Collections.emptyList();
        }

        List<AppOrderController.TimelineEventVO> events = new ArrayList<>();
        int lastStepIndex = -1;
        for (DsOrderProgress progress : progressList) {
            int currentIndex = findCurrentStepIndex(steps, progress.getStepId());
            String eventType = resolveTimelineEventType(progress, currentIndex, lastStepIndex);

            AppOrderController.TimelineEventVO event = new AppOrderController.TimelineEventVO();
            event.setProgressId(progress.getProgressId());
            event.setStepId(progress.getStepId());
            event.setStepName(resolveStepName(steps, progress.getStepId()));
            event.setDescription(progress.getDescription());
            event.setImageUrls(progress.getImageUrls());
            event.setCreateTime(progress.getCreateTime());
            event.setEventType(eventType);
            event.setEventLabel(resolveTimelineEventLabel(eventType));
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

    private void recordProgress(Long orderId, Long stepId, String description, String imageUrls) {
        LoginUser loginUser = LoginHelper.getLoginUser();
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(stepId);
        progress.setDescription(description);
        progress.setImageUrls(normalizeJsonField(imageUrls));
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
        orderMapper.updateById(order);

        String description = StringUtils.hasText(dto.getDescription())
                ? dto.getDescription()
                : "退回至节点：" + targetStep.getStepName();
        recordProgress(order.getOrderId(), targetStep.getStepId(), description, dto.getImageUrls());
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

    private String normalizeJsonField(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
