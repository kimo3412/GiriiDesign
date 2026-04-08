package com.designstudio.order.controller;

import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 小程序端 - 我的订单接口
 */
@RestController
@RequestMapping("/api/v1/app/orders")
@RequiredArgsConstructor
@Tag(name = "C端-我的订单")
public class AppOrderController {

    private final OrderService orderService;

    @GetMapping("/my")
    @Operation(summary = "我的订单列表")
    public R<List<DsOrder>> myOrders(@RequestParam(required = false) Integer status) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        return R.ok(orderService.getMyOrders(userId, status));
    }

    @GetMapping("/{id}")
    @Operation(summary = "订单详情及进度时间轴")
    public R<OrderController.OrderDetailVO> detail(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        OrderController.OrderDetailVO vo = orderService.getAppOrderDetail(id, userId);
        if (vo == null) return R.fail("订单不存在或无权查看");
        return R.ok(vo);
    }

    @PostMapping("/{id}/pay")
    @Operation(summary = "模拟支付定金/尾款")
    public R<Void> payOrder(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        try {
            orderService.payOrder(id, userId);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }
}
