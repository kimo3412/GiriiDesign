package com.designstudio.order.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.designstudio.order.controller.AppOrderController;
import com.designstudio.order.controller.OrderController;
import com.designstudio.order.controller.WorkbenchController;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderProgress;
import com.designstudio.supply.domain.DsBomItem;

import java.util.List;

/**
 * 订单业务 Service
 */
public interface OrderService {

    /**
     * 订单列表（支持分页、筛选）
     */
    IPage<DsOrder> listOrders(Integer status, Long categoryId, Long designerId, Long pageNum, Long pageSize);

    /**
     * 订单详情（360° 视图）
     */
    OrderController.OrderDetailVO getOrderDetail(Long orderId);

    /**
     * 看板数据
     */
    List<OrderController.KanbanColumnVO> getKanbanData(Long categoryId);

    /**
     * 推进订单到下一个工作流节点
     */
    void advance(Long orderId, OrderController.AdvanceDTO dto);

    /**
     * 阻塞订单
     */
    void block(Long orderId, String blockReason);

    /**
     * 解除阻塞
     */
    void unblock(Long orderId);

    void cancel(Long orderId, String cancelReason);

    void delay(Long orderId, OrderController.DelayDTO dto);

    void ship(Long orderId, String description);

    /**
     * 获取订单进度时间轴
     */
    List<DsOrderProgress> getProgressList(Long orderId);

    /**
     * 添加进度记录
     */
    void addProgress(Long orderId, OrderController.ProgressDTO dto);

    /**
     * 模拟支付定金/尾款（C端）
     */
    void payOrder(Long orderId, Long userId);

    void confirm(Long orderId, Long userId);

    /**
     * C端 - 我的订单列表
     */
    List<DsOrder> getMyOrders(Long userId, Integer status);

    /**
     * C端 - 订单详情及进度时间轴
     */
    OrderController.OrderDetailVO getAppOrderDetail(Long orderId, Long userId);

    WorkbenchController.WorkbenchVO getWorkbenchData(Long categoryId, Long stepId);

    void handleWorkbenchAction(Long orderId, WorkbenchController.WorkbenchActionDTO dto);

    AppOrderController.OrderTimelineVO getOrderTimeline(Long orderId, Long userId);

    /**
     * 获取订单BOM物料明细
     */
    List<DsBomItem> getOrderBom(Long orderId);
}
