package com.designstudio.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.config.domain.DsWorkflow;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.config.mapper.DsWorkflowMapper;
import com.designstudio.config.mapper.DsWorkflowStepMapper;
import com.designstudio.order.controller.RequestController;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderRequest;
import com.designstudio.order.mapper.DsOrderMapper;
import com.designstudio.order.mapper.DsOrderRequestMapper;
import com.designstudio.order.service.RequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 意向单业务 Service 实现
 */
@Service
@RequiredArgsConstructor
public class RequestServiceImpl implements RequestService {

    private final DsOrderRequestMapper requestMapper;
    private final DsOrderMapper orderMapper;
    private final DsWorkflowMapper workflowMapper;
    private final DsWorkflowStepMapper workflowStepMapper;

    @Override
    public List<DsOrderRequest> listRequests(Integer status, Long categoryId) {
        LambdaQueryWrapper<DsOrderRequest> wrapper = new LambdaQueryWrapper<>();
        if (status != null) {
            wrapper.eq(DsOrderRequest::getStatus, status);
        }
        if (categoryId != null) {
            wrapper.eq(DsOrderRequest::getCategoryId, categoryId);
        }
        wrapper.orderByDesc(DsOrderRequest::getCreateTime);
        return requestMapper.selectList(wrapper);
    }

    @Override
    public DsOrderRequest getRequest(Long id) {
        return requestMapper.selectById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DsOrder convert(Long requestId, RequestController.ConvertDTO dto) {
        DsOrderRequest request = requestMapper.selectById(requestId);
        if (request == null) {
            throw new RuntimeException("意向不存在");
        }
        if (request.getStatus() != 0) {
            throw new RuntimeException("只有待处理状态的意向才能转单");
        }

        DsOrder order = new DsOrder();
        order.setOrderSn(generateOrderSn());
        order.setUserId(request.getUserId());
        order.setCategoryId(request.getCategoryId());
        order.setDesignerId(dto.getDesignerId());
        order.setCustomDataSnapshot(request.getCustomData());
        order.setTotalAmount(dto.getTotalAmount());
        order.setPrepayAmount(dto.getPrepayAmount());
        order.setPaidAmount(BigDecimal.ZERO);
        order.setExpectedDate(dto.getExpectedDate());
        order.setRemark(dto.getRemark());
        order.setStatus(0);
        order.setIsBlocked(0);

        DsWorkflow workflow = workflowMapper.selectOne(
                new LambdaQueryWrapper<DsWorkflow>().eq(DsWorkflow::getCategoryId, request.getCategoryId()));
        if (workflow != null) {
            LambdaQueryWrapper<DsWorkflowStep> stepWrapper = new LambdaQueryWrapper<>();
            stepWrapper.eq(DsWorkflowStep::getWorkflowId, workflow.getWorkflowId());
            stepWrapper.orderByAsc(DsWorkflowStep::getStepOrder);
            stepWrapper.last("limit 1");
            DsWorkflowStep firstStep = workflowStepMapper.selectOne(stepWrapper);
            if (firstStep != null) {
                order.setCurrentStepId(firstStep.getStepId());
            }
        }

        orderMapper.insert(order);

        request.setStatus(1);
        request.setLinkedOrderId(order.getOrderId());
        requestMapper.updateById(request);

        return order;
    }

    @Override
    public void close(Long requestId, String closeReason) {
        DsOrderRequest request = requestMapper.selectById(requestId);
        if (request == null) throw new RuntimeException("意向不存在");
        if (request.getStatus() != 0) throw new RuntimeException("只有待处理状态的意向才能关闭");

        request.setStatus(2);
        request.setCloseReason(closeReason);
        requestMapper.updateById(request);
    }

    @Override
    public void submit(DsOrderRequest request, Long userId) {
        request.setUserId(userId);
        request.setStatus(0);
        requestMapper.insert(request);
    }

    @Override
    public List<DsOrderRequest> getMyRequests(Long userId, Integer status) {
        LambdaQueryWrapper<DsOrderRequest> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DsOrderRequest::getUserId, userId);
        if (status != null) {
            wrapper.eq(DsOrderRequest::getStatus, status);
        }
        wrapper.orderByDesc(DsOrderRequest::getCreateTime);
        return requestMapper.selectList(wrapper);
    }

    private String generateOrderSn() {
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = ThreadLocalRandom.current().nextInt(1000, 9999);
        return "DS" + dateStr + random;
    }
}
