package com.designstudio.order.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.order.domain.DsOrderRequest;
import com.designstudio.order.mapper.DsOrderRequestMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 小程序端 - 意向申请接口
 */
@RestController
@RequestMapping("/api/v1/app/requests")
@RequiredArgsConstructor
@Tag(name = "C端-意向管理")
public class AppRequestController {

    private final DsOrderRequestMapper requestMapper;

    @PostMapping
    @Operation(summary = "提交定制意向")
    public R<Void> submit(@RequestBody DsOrderRequest request) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        // 绑定当前用户
        request.setUserId(userId);
        request.setStatus(0); // 待处理
        requestMapper.insert(request);
        return R.ok();
    }

    @GetMapping("/my")
    @Operation(summary = "我的意向列表")
    public R<List<DsOrderRequest>> myRequests(@RequestParam(required = false) Integer status) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        LambdaQueryWrapper<DsOrderRequest> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DsOrderRequest::getUserId, userId);
        if (status != null) {
            wrapper.eq(DsOrderRequest::getStatus, status);
        }
        wrapper.orderByDesc(DsOrderRequest::getCreateTime);

        return R.ok(requestMapper.selectList(wrapper));
    }
}
