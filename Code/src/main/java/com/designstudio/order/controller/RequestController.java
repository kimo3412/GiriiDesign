package com.designstudio.order.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.designstudio.common.exception.BusinessException;
import com.designstudio.common.result.ErrorCode;
import com.designstudio.common.result.R;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderRequest;
import com.designstudio.order.mapper.DsOrderMapper;
import com.designstudio.order.mapper.DsOrderRequestMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 意向管理 Controller
 */
@RestController
@RequestMapping("/api/v1/admin/requests")
@RequiredArgsConstructor
@Tag(name = "意向管理")
public class RequestController {

    private final DsOrderRequestMapper requestMapper;
    private final DsOrderMapper orderMapper;

    @GetMapping
    @Operation(summary = "获取意向列表")
    public R<List<DsOrderRequest>> list(
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long categoryId) {
        LambdaQueryWrapper<DsOrderRequest> wrapper = new LambdaQueryWrapper<>();
        if (status != null) {
            wrapper.eq(DsOrderRequest::getStatus, status);
        }
        if (categoryId != null) {
            wrapper.eq(DsOrderRequest::getCategoryId, categoryId);
        }
        wrapper.orderByDesc(DsOrderRequest::getCreateTime);
        return R.ok(requestMapper.selectList(wrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取意向详情")
    public R<DsOrderRequest> get(@PathVariable Long id) {
        return R.ok(requestMapper.selectById(id));
    }

    @PostMapping("/{requestId}/convert")
    @Operation(summary = "意向转正订单")
    @Transactional(rollbackFor = Exception.class)
    public R<DsOrder> convert(@PathVariable Long requestId, @RequestBody ConvertDTO dto) {
        DsOrderRequest request = requestMapper.selectById(requestId);
        if (request == null) {
            return R.fail("意向不存在");
        }
        if (request.getStatus() != 0) {
            return R.fail("只有待处理状态的意向才能转单");
        }

        // 1. 创建订单
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
        order.setStatus(1); // 直接进入生产中（简化流程）
        order.setIsBlocked(0);
        orderMapper.insert(order);

        // 2. 更新意向状态
        request.setStatus(1); // 已转单
        request.setLinkedOrderId(order.getOrderId());
        requestMapper.updateById(request);

        return R.ok(order);
    }

    @PostMapping("/{requestId}/close")
    @Operation(summary = "关闭意向")
    public R<Void> close(@PathVariable Long requestId, @RequestBody CloseDTO dto) {
        DsOrderRequest request = requestMapper.selectById(requestId);
        if (request == null) {
            return R.fail("意向不存在");
        }
        if (request.getStatus() != 0) {
            return R.fail("只有待处理状态的意向才能关闭");
        }

        request.setStatus(2); // 已关闭
        request.setCloseReason(dto.getCloseReason());
        requestMapper.updateById(request);
        return R.ok();
    }

    /** 生成订单编号: DS + yyyyMMddHHmmss + 4位随机数 */
    private String generateOrderSn() {
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = ThreadLocalRandom.current().nextInt(1000, 9999);
        return "DS" + dateStr + random;
    }

    @Data
    public static class ConvertDTO {
        private Long designerId;
        private BigDecimal totalAmount;
        private BigDecimal prepayAmount;
        private LocalDate expectedDate;
        private String remark;
    }

    @Data
    public static class CloseDTO {
        private String closeReason;
    }
}
