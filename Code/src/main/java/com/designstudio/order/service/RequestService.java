package com.designstudio.order.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.designstudio.order.controller.RequestController;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderRequest;

import java.util.List;

/**
 * 意向单业务 Service
 */
public interface RequestService {

    /**
     * 意向列表（分页）
     */
    IPage<DsOrderRequest> listRequests(Integer status, Long categoryId, Long pageNum, Long pageSize);

    /**
     * 意向详情
     */
    DsOrderRequest getRequest(Long id);

    /**
     * 意向转正订单
     */
    DsOrder convert(Long requestId, RequestController.ConvertDTO dto);

    /**
     * 关闭意向
     */
    void close(Long requestId, String closeReason);

    /**
     * C端 - 提交定制意向
     */
    void submit(DsOrderRequest request, Long userId);

    /**
     * C端 - 我的意向列表
     */
    List<DsOrderRequest> getMyRequests(Long userId, Integer status);
}
