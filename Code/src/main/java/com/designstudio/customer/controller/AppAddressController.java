package com.designstudio.customer.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.customer.domain.DsAddress;
import com.designstudio.customer.mapper.DsAddressMapper;
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

    private final DsAddressMapper addressMapper;

    @GetMapping("/list")
    @Operation(summary = "获取当前用户的所有地址")
    public R<List<DsAddress>> list() {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        List<DsAddress> list = addressMapper.selectList(
                new LambdaQueryWrapper<DsAddress>()
                        .eq(DsAddress::getUserId, userId)
                        .orderByDesc(DsAddress::getIsDefault)
                        .orderByDesc(DsAddress::getCreateTime)
        );
        return R.ok(list);
    }

    @PostMapping
    @Operation(summary = "新增地址")
    public R<Void> add(@RequestBody DsAddress address) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        address.setUserId(userId);
        
        // 如果是默认地址，或者这是第一条地址，则重置其他
        handleDefaultLogic(userId, address);
        
        addressMapper.insert(address);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新地址")
    public R<Void> update(@PathVariable Long id, @RequestBody DsAddress address) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        
        address.setAddressId(id);
        address.setUserId(userId);

        handleDefaultLogic(userId, address);

        addressMapper.updateById(address);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除地址")
    public R<Void> delete(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        addressMapper.delete(new LambdaQueryWrapper<DsAddress>()
                .eq(DsAddress::getAddressId, id)
                .eq(DsAddress::getUserId, userId));
        return R.ok();
    }

    @PutMapping("/{id}/default")
    @Operation(summary = "设为默认地址")
    public R<Void> setDefault(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        DsAddress address = new DsAddress();
        address.setAddressId(id);
        address.setUserId(userId);
        address.setIsDefault(true);
        
        handleDefaultLogic(userId, address);
        
        addressMapper.updateById(address);
        return R.ok();
    }

    /**
     * 处理默认地址互斥逻辑
     */
    private void handleDefaultLogic(Long userId, DsAddress address) {
        if (Boolean.TRUE.equals(address.getIsDefault())) {
            // 将该用户其他的地址设为非默认
            DsAddress updateObj = new DsAddress();
            updateObj.setIsDefault(false);
            addressMapper.update(updateObj, new LambdaQueryWrapper<DsAddress>()
                    .eq(DsAddress::getUserId, userId));
        } else {
            // 如果用户当前没有地址，自动把第一条存为默认
            Long count = addressMapper.selectCount(new LambdaQueryWrapper<DsAddress>()
                    .eq(DsAddress::getUserId, userId));
            if (count == 0) {
                address.setIsDefault(true);
            }
        }
    }
}
