package com.designstudio.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
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
import com.designstudio.supply.domain.DsBomItem;
import com.designstudio.supply.domain.DsBomTemplateItem;
import com.designstudio.supply.domain.DsMaterial;
import com.designstudio.supply.mapper.DsBomItemMapper;
import com.designstudio.supply.mapper.DsBomTemplateItemMapper;
import com.designstudio.supply.mapper.DsMaterialMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
    private final DsBomTemplateItemMapper bomTemplateItemMapper;
    private final DsMaterialMapper materialMapper;
    private final DsBomItemMapper bomItemMapper;
    private final ObjectMapper objectMapper;

    @Override
    public IPage<DsOrderRequest> listRequests(Integer status, Long categoryId, String keyword, Long pageNum, Long pageSize) {
        LambdaQueryWrapper<DsOrderRequest> wrapper = new LambdaQueryWrapper<>();
        if (status != null) {
            wrapper.eq(DsOrderRequest::getStatus, status);
        }
        if (categoryId != null) {
            wrapper.eq(DsOrderRequest::getCategoryId, categoryId);
        }
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            Long idKeyword = null;
            try {
                idKeyword = Long.valueOf(kw);
            } catch (NumberFormatException ignored) {
                // Non-numeric keywords only search text columns.
            }
            Long finalIdKeyword = idKeyword;
            wrapper.and(w -> {
                w.like(DsOrderRequest::getDescription, kw)
                        .or().like(DsOrderRequest::getCustomData, kw)
                        .or().like(DsOrderRequest::getCloseReason, kw);
                if (finalIdKeyword != null) {
                    w.or().eq(DsOrderRequest::getRequestId, finalIdKeyword)
                            .or().eq(DsOrderRequest::getUserId, finalIdKeyword)
                            .or().eq(DsOrderRequest::getLinkedOrderId, finalIdKeyword);
                }
            });
        }
        wrapper.orderByDesc(DsOrderRequest::getCreateTime);
        Page<DsOrderRequest> page = new Page<>(pageNum, pageSize);
        return requestMapper.selectPage(page, wrapper);
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
        order.setBomTemplateId(dto.getBomTemplateId());

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

        // 生成订单 BOM 明细 + 计算物料成本
        if (dto.getBomTemplateId() != null) {
            generateOrderBom(order.getOrderId(), dto.getBomTemplateId());
        }

        request.setStatus(1);
        request.setLinkedOrderId(order.getOrderId());
        int updated = requestMapper.update(null,
                new LambdaUpdateWrapper<DsOrderRequest>()
                        .eq(DsOrderRequest::getRequestId, requestId)
                        .eq(DsOrderRequest::getStatus, 0)
                        .set(DsOrderRequest::getStatus, 1)
                        .set(DsOrderRequest::getLinkedOrderId, order.getOrderId()));
        if (updated != 1) {
            throw new RuntimeException("意向状态已变化，请刷新后重试");
        }

        return order;
    }

    @Override
    public void close(Long requestId, String closeReason) {
        DsOrderRequest request = requestMapper.selectById(requestId);
        if (request == null) throw new RuntimeException("意向不存在");
        if (request.getStatus() != 0) throw new RuntimeException("只有待处理状态的意向才能关闭");

        request.setStatus(2);
        request.setCloseReason(closeReason);
        int updated = requestMapper.update(null,
                new LambdaUpdateWrapper<DsOrderRequest>()
                        .eq(DsOrderRequest::getRequestId, requestId)
                        .eq(DsOrderRequest::getStatus, 0)
                        .set(DsOrderRequest::getStatus, 2)
                        .set(DsOrderRequest::getCloseReason, closeReason));
        if (updated != 1) {
            throw new RuntimeException("意向状态已变化，请刷新后重试");
        }
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

    /**
     * 根据 BOM 模板生成订单物料明细，计算物料成本
     */
    private void generateOrderBom(Long orderId, Long templateId) {
        // 查询模板明细
        List<DsBomTemplateItem> templateItems = bomTemplateItemMapper.selectList(
                new LambdaQueryWrapper<DsBomTemplateItem>()
                        .eq(DsBomTemplateItem::getTemplateId, templateId));
        if (templateItems.isEmpty()) return;

        BigDecimal totalCost = BigDecimal.ZERO;

        for (DsBomTemplateItem item : templateItems) {
            DsMaterial material = materialMapper.selectById(item.getMaterialId());
            if (material == null) continue;

            BigDecimal subtotal = material.getUnitPrice().multiply(item.getQuantity());
            totalCost = totalCost.add(subtotal);

            // 物料快照
            Map<String, Object> snapshot = new HashMap<>();
            snapshot.put("name", material.getName());
            snapshot.put("sku", material.getSku());
            snapshot.put("unitPrice", material.getUnitPrice());
            snapshot.put("unit", material.getUnit());

            DsBomItem bomItem = new DsBomItem();
            bomItem.setOrderId(orderId);
            bomItem.setMaterialId(item.getMaterialId());
            bomItem.setQuantity(item.getQuantity());
            try {
                bomItem.setMaterialSnapshot(objectMapper.writeValueAsString(snapshot));
            } catch (JsonProcessingException e) {
                bomItem.setMaterialSnapshot("{}");
            }
            bomItem.setIsAllocated(0);
            bomItem.setDelFlag(0);
            bomItemMapper.insert(bomItem);
        }

        // 更新订单物料成本
        DsOrder order = orderMapper.selectById(orderId);
        order.setMaterialCost(totalCost);
        orderMapper.updateById(order);
    }
}
