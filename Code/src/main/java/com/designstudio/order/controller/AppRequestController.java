package com.designstudio.order.controller;

import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.order.domain.DsOrderRequest;
import com.designstudio.order.service.RequestService;
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

    private final RequestService requestService;

    @PostMapping
    @Operation(summary = "提交定制意向")
    public R<Void> submit(@RequestBody DsOrderRequest request) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        requestService.submit(request, userId);
        return R.ok();
    }

    @GetMapping("/my")
    @Operation(summary = "我的意向列表")
    public R<List<DsOrderRequest>> myRequests(@RequestParam(required = false) Integer status) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        return R.ok(requestService.getMyRequests(userId, status));
    }
}
