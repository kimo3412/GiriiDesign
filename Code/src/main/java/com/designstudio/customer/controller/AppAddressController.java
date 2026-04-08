package com.designstudio.customer.controller;

import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.customer.domain.DsAddress;
import com.designstudio.customer.service.AddressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 小程序端 - 地址管理接口
 */
@RestController
@RequestMapping("/api/v1/app/address")
@RequiredArgsConstructor
@Tag(name = "C端-地址管理")
public class AppAddressController {

    private final AddressService addressService;

    @GetMapping("/list")
    @Operation(summary = "获取当前用户的所有地址")
    public R<List<DsAddress>> list() {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        return R.ok(addressService.listAddresses(userId));
    }

    @PostMapping
    @Operation(summary = "新增地址")
    public R<Void> add(@RequestBody DsAddress address) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        addressService.addAddress(userId, address);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新地址")
    public R<Void> update(@PathVariable Long id, @RequestBody DsAddress address) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        addressService.updateAddress(userId, id, address);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除地址")
    public R<Void> delete(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        addressService.deleteAddress(userId, id);
        return R.ok();
    }

    @PutMapping("/{id}/default")
    @Operation(summary = "设为默认地址")
    public R<Void> setDefault(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        addressService.setDefault(userId, id);
        return R.ok();
    }
}
