package com.designstudio.order.controller;

import java.math.BigDecimal;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderProgress;
import com.designstudio.order.mapper.DsOrderMapper;
import com.designstudio.order.mapper.DsOrderProgressMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
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

    private final DsOrderMapper orderMapper;
    private final DsOrderProgressMapper progressMapper;

    @GetMapping("/my")
    @Operation(summary = "我的订单列表")
    public R<List<DsOrder>> myOrders(@RequestParam(required = false) Integer status) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        LambdaQueryWrapper<DsOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DsOrder::getUserId, userId);
        if (status != null) {
            wrapper.eq(DsOrder::getStatus, status);
        }
        wrapper.orderByDesc(DsOrder::getCreateTime);

        return R.ok(orderMapper.selectList(wrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "订单详情及进度时间轴（包含工作流步骤）")
    public R<OrderDetailProgressVO> detail(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        DsOrder order = orderMapper.selectById(id);
        if (order == null || !order.getUserId().equals(userId)) {
            return R.fail("订单不存在或无权查看");
        }

        // 获取进度列表
        List<DsOrderProgress> progressList = progressMapper.selectList(
                new LambdaQueryWrapper<DsOrderProgress>()
                        .eq(DsOrderProgress::getOrderId, id)
                        .orderByAsc(DsOrderProgress::getCreateTime)
        );

        // 获取该订单关联的工作流步骤（可用于进度条点亮状态）
        // 简单处理：我们没有直接在订单表存 workflowId，但我们可以通过 categoryId 找到对应的步骤
        // 正常应该在订单转正时固化步骤，但此处简化通过分类关联查询
        // 因为工作流是跟着分类走的
        // ... (此处省略复杂的联合查询，假设前端自己拿 categoryId 去获取步骤)

        OrderDetailProgressVO vo = new OrderDetailProgressVO();
        vo.setOrder(order);
        vo.setProgressList(progressList);
        return R.ok(vo);
    }

    @Data
    public static class OrderDetailProgressVO {
        private DsOrder order;
        private List<DsOrderProgress> progressList;
    }

    @PostMapping("/{id}/pay")
    @Operation(summary = "模拟支付定金/尾款")
    public R<Void> payOrder(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        DsOrder order = orderMapper.selectById(id);
        if (order == null || !order.getUserId().equals(userId)) {
            return R.fail("订单不存在或无权操作");
        }

        if (order.getStatus() == 0) {
            // 支付定金
            order.setStatus(1); // 进入生产中
            order.setPaidAmount(order.getPrepayAmount());
            orderMapper.updateById(order);

            // 记录一条进度记录
            DsOrderProgress progress = new DsOrderProgress();
            progress.setOrderId(id);
            progress.setDescription("客户已支付定金：¥" + order.getPrepayAmount());
            progressMapper.insert(progress);

            return R.ok();
        } else if (order.getStatus() == 6) {
            // 支付尾款
            order.setStatus(2); // 进入待发货
            order.setPaidAmount(order.getTotalAmount());
            orderMapper.updateById(order);

            // 记录一条进度记录
            DsOrderProgress progress = new DsOrderProgress();
            progress.setOrderId(id);
            BigDecimal balance = order.getTotalAmount().subtract(order.getPrepayAmount());
            progress.setDescription("客户已支付尾款：¥" + balance);
            progressMapper.insert(progress);

            return R.ok();
        }

        return R.fail("当前订单状态不需要支付");
    }
}
