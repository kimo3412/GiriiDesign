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
import com.designstudio.order.controller.AppOrderController;
import com.designstudio.order.controller.OrderController;
import com.designstudio.order.controller.WorkbenchController;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderProgress;
import com.designstudio.order.mapper.DsOrderMapper;
import com.designstudio.order.mapper.DsOrderProgressMapper;
import com.designstudio.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 订单业务 Service 实现
 */
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final DsOrderMapper orderMapper;
    private final DsOrderProgressMapper progressMapper;
    private final DsWorkflowMapper workflowMapper;
    private final DsWorkflowStepMapper stepMapper;
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
        return orderMapper.selectList(wrapper);
    }

    @Override
    public OrderController.OrderDetailVO getOrderDetail(Long orderId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            return null;
        }

        List<DsWorkflowStep> allSteps = Collections.emptyList();
        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>().eq(DsWorkflow::getCategoryId, order.getCategoryId()));
        if (workflow != null) {
            allSteps = stepMapper.selectList(
                    new LambdaQueryWrapper<DsWorkflowStep>()
                            .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId())
                            .orderByAsc(DsWorkflowStep::getStepOrder));
        }

        List<DsOrderProgress> progressList = progressMapper.selectList(
                new LambdaQueryWrapper<DsOrderProgress>()
                        .eq(DsOrderProgress::getOrderId, orderId)
                        .orderByAsc(DsOrderProgress::getCreateTime));

        OrderController.OrderDetailVO vo = new OrderController.OrderDetailVO();
        vo.setOrder(order);
        vo.setWorkflowSteps(allSteps);
        vo.setProgressList(progressList);
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
                .filter(o -> o.getCurrentStepId() != null)
                .collect(Collectors.groupingBy(DsOrder::getCurrentStepId));

        Map<Long, Long> stepCategoryMap = new HashMap<>();
        for (DsWorkflowStep step : allSteps) {
            stepCategoryMap.put(step.getStepId(), workflowCategoryMap.get(step.getWorkflowId()));
        }

        return allSteps.stream().map(step -> {
            OrderController.KanbanColumnVO col = new OrderController.KanbanColumnVO();
            col.setStepId(step.getStepId());
            col.setStepName(step.getStepName());
            col.setStepOrder(step.getStepOrder());
            col.setCategoryId(stepCategoryMap.get(step.getStepId()));
            col.setOrders(ordersByStep.getOrDefault(step.getStepId(), Collections.emptyList()));
            return col;
        }).collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void advance(Long orderId, OrderController.AdvanceDTO dto) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) throw new RuntimeException("订单不存在");
        if (order.getStatus() != 1) throw new RuntimeException("只有生产中的订单才能推进");
        if (order.getIsBlocked() != null && order.getIsBlocked() == 1) throw new RuntimeException("订单已阻塞，请先解除阻塞");

        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>().eq(DsWorkflow::getCategoryId, order.getCategoryId()));
        if (workflow == null) throw new RuntimeException("该品类未配置工作流");

        List<DsWorkflowStep> steps = stepMapper.selectList(
                new LambdaQueryWrapper<DsWorkflowStep>()
                        .eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId())
                        .orderByAsc(DsWorkflowStep::getStepOrder));

        if (steps.isEmpty()) throw new RuntimeException("工作流没有节点");

        Long currentStepId = order.getCurrentStepId();
        DsWorkflowStep nextStep = null;

        if (currentStepId == null) {
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
            if (order.getTotalAmount() != null && order.getPrepayAmount() != null &&
                order.getTotalAmount().compareTo(order.getPrepayAmount()) > 0) {
                order.setStatus(6);

                LoginUser loginUser = LoginHelper.getLoginUser();
                DsOrderProgress progress = new DsOrderProgress();
                progress.setOrderId(orderId);
                progress.setDescription("生产完毕，等待客户支付尾款");
                progress.setOperatorId(loginUser.getAdminId());
                progress.setCreateTime(LocalDateTime.now());
                progressMapper.insert(progress);
            } else {
                order.setStatus(2);
            }
            order.setFinishTime(LocalDateTime.now());
            orderMapper.updateById(order);
            return;
        }

        order.setCurrentStepId(nextStep.getStepId());
        orderMapper.updateById(order);

        LoginUser loginUser = LoginHelper.getLoginUser();
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(nextStep.getStepId());
        progress.setDescription(dto.getDescription() != null ? dto.getDescription()
                : "推进至节点：" + nextStep.getStepName());
        progress.setImageUrls(normalizeJsonField(dto.getImageUrls()));
        progress.setOperatorId(loginUser.getAdminId());
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);
    }

    @Override
    public void block(Long orderId, String blockReason) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) throw new RuntimeException("订单不存在");

        order.setIsBlocked(1);
        order.setBlockReason(blockReason);
        orderMapper.updateById(order);
    }

    @Override
    public void unblock(Long orderId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) throw new RuntimeException("订单不存在");

        order.setIsBlocked(0);
        order.setBlockReason(null);
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
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) throw new RuntimeException("订单不存在");

        LoginUser loginUser = LoginHelper.getLoginUser();
        DsOrderProgress progress = new DsOrderProgress();
        progress.setOrderId(orderId);
        progress.setStepId(order.getCurrentStepId());
        progress.setDescription(dto.getDescription());
        progress.setImageUrls(normalizeJsonField(dto.getImageUrls()));
        progress.setOperatorId(loginUser.getAdminId());
        progress.setCreateTime(LocalDateTime.now());
        progress.setDelFlag(0);
        progressMapper.insert(progress);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void payOrder(Long orderId, Long userId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            throw new RuntimeException("订单不存在或无权操作");
        }

        if (order.getStatus() == 0) {
            order.setStatus(1);
            order.setPaidAmount(order.getPrepayAmount());
            orderMapper.updateById(order);

            DsOrderProgress progress = new DsOrderProgress();
            progress.setOrderId(orderId);
            progress.setDescription("客户已支付定金：¥" + order.getPrepayAmount());
            progressMapper.insert(progress);
        } else if (order.getStatus() == 6) {
            order.setStatus(2);
            order.setPaidAmount(order.getTotalAmount());
            orderMapper.updateById(order);

            DsOrderProgress progress = new DsOrderProgress();
            progress.setOrderId(orderId);
            BigDecimal balance = order.getTotalAmount().subtract(order.getPrepayAmount());
            progress.setDescription("客户已支付尾款：¥" + balance);
            progressMapper.insert(progress);
        } else {
            throw new RuntimeException("当前订单状态不需要支付");
        }
    }

    @Override
    public List<DsOrder> getMyOrders(Long userId, Integer status) {
        LambdaQueryWrapper<DsOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DsOrder::getUserId, userId);
        if (status != null) {
            wrapper.eq(DsOrder::getStatus, status);
        }
        wrapper.orderByDesc(DsOrder::getCreateTime);
        return orderMapper.selectList(wrapper);
    }

    @Override
    public OrderController.OrderDetailVO getAppOrderDetail(Long orderId, Long userId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            return null;
        }

        List<DsWorkflowStep> allSteps = getWorkflowStepsByCategory(order.getCategoryId());
        List<DsOrderProgress> progressList = progressMapper.selectList(
                new LambdaQueryWrapper<DsOrderProgress>()
                        .eq(DsOrderProgress::getOrderId, orderId)
                        .orderByAsc(DsOrderProgress::getCreateTime));

        OrderController.OrderDetailVO vo = new OrderController.OrderDetailVO();
        vo.setOrder(order);
        vo.setWorkflowSteps(allSteps);
        vo.setProgressList(progressList);
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
        vo.setOrders(orderMapper.selectList(wrapper));
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleWorkbenchAction(Long orderId, WorkbenchController.WorkbenchActionDTO dto) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

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

        if ("block".equals(action)) {
            block(orderId, dto.getBlockReason());
            recordProgress(orderId, order.getCurrentStepId(),
                    dto.getDescription() != null ? dto.getDescription() : "订单已阻塞：" + dto.getBlockReason(),
                    dto.getImageUrls());
            return;
        }

        if ("unblock".equals(action)) {
            unblock(orderId);
            recordProgress(orderId, order.getCurrentStepId(),
                    dto.getDescription() != null ? dto.getDescription() : "订单已解除阻塞",
                    dto.getImageUrls());
            return;
        }

        throw new RuntimeException("不支持的工作台动作");
    }

    @Override
    public AppOrderController.OrderTimelineVO getOrderTimeline(Long orderId, Long userId) {
        DsOrder order = orderMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            return null;
        }

        List<DsWorkflowStep> allSteps = getWorkflowStepsByCategory(order.getCategoryId()).stream()
                .filter(step -> step.getVisibleToClient() == null || step.getVisibleToClient() == 1)
                .collect(Collectors.toList());
        List<DsOrderProgress> progressList = getProgressList(orderId);

        AppOrderController.OrderTimelineVO vo = new AppOrderController.OrderTimelineVO();
        vo.setOrder(order);
        vo.setWorkflowSteps(allSteps);
        vo.setProgressList(progressList);
        vo.setCurrentStepIndex(resolveTimelineStepIndex(allSteps, order.getCurrentStepId(), progressList));
        return vo;
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
            return new HashSet<>(Arrays.asList("save", "advance", "block", "unblock"));
        }
        try {
            List<String> actions = objectMapper.readValue(
                    currentStep.getAllowedActions(),
                    new TypeReference<List<String>>() {});
            return new HashSet<>(actions);
        } catch (Exception ignored) {
            return new HashSet<>(Arrays.asList("save", "advance", "block", "unblock"));
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
