package com.designstudio.customer.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.designstudio.common.result.ListWithStats;
import com.designstudio.common.result.PageResult;
import com.designstudio.common.result.R;
import com.designstudio.customer.domain.DsAddress;
import com.designstudio.customer.domain.DsUser;
import com.designstudio.customer.mapper.DsAddressMapper;
import com.designstudio.customer.mapper.DsUserMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 后台 - 客户管理
 */
@RestController
@RequestMapping("/api/v1/admin/customers")
@RequiredArgsConstructor
@Tag(name = "客户管理")
public class AdminCustomerController {

    private final DsUserMapper userMapper;
    private final DsAddressMapper addressMapper;

    @GetMapping
    @Operation(summary = "客户列表（分页）")
    public R<ListWithStats<CustomerListVO>> listCustomers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Long pageNum,
            @RequestParam(defaultValue = "10") Long pageSize) {
        LambdaQueryWrapper<DsUser> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(DsUser::getNickname, keyword).or().like(DsUser::getPhone, keyword));
        }
        if (status != null) {
            wrapper.eq(DsUser::getStatus, status);
        }
        wrapper.orderByDesc(DsUser::getCreateTime);

        IPage<DsUser> page = userMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        List<Long> userIds = page.getRecords().stream().map(DsUser::getUserId).collect(Collectors.toList());
        Map<Long, List<DsAddress>> addressesByUser = loadAddressesByUserIds(userIds);

        List<CustomerListVO> records = page.getRecords().stream().map(user -> {
            List<DsAddress> addresses = addressesByUser.getOrDefault(user.getUserId(), Collections.emptyList());
            CustomerListVO vo = new CustomerListVO();
            vo.setUserId(user.getUserId());
            vo.setNickname(user.getNickname());
            vo.setAvatarUrl(user.getAvatarUrl());
            vo.setPhone(user.getPhone());
            vo.setStatus(user.getStatus());
            vo.setLastLoginTime(user.getLastLoginTime());
            vo.setCreateTime(user.getCreateTime());
            vo.setAddressCount(addresses.size());
            vo.setDefaultAddress(formatDefaultAddress(addresses));
            return vo;
        }).collect(Collectors.toList());

        LambdaQueryWrapper<DsUser> countWrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            countWrapper.and(w -> w.like(DsUser::getNickname, keyword).or().like(DsUser::getPhone, keyword));
        }
        List<DsUser> allUsers = userMapper.selectList(countWrapper);
        long enabledCount = allUsers.stream().filter(u -> u.getStatus() == 1).count();
        long disabledCount = allUsers.stream().filter(u -> u.getStatus() == 0).count();
        Map<String, Long> stats = new HashMap<>();
        stats.put("enabled", enabledCount);
        stats.put("disabled", disabledCount);

        return R.ok(ListWithStats.of(records, page.getTotal(), page.getCurrent(), page.getSize()).stats(stats));
    }

    @GetMapping("/addresses")
    @Operation(summary = "地址列表（分页）")
    public R<PageResult<CustomerAddressVO>> listAddresses(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long userId,
            @RequestParam(defaultValue = "1") Long pageNum,
            @RequestParam(defaultValue = "10") Long pageSize) {
        LambdaQueryWrapper<DsAddress> wrapper = new LambdaQueryWrapper<>();
        if (userId != null) {
            wrapper.eq(DsAddress::getUserId, userId);
        }

        List<Long> matchedUserIds = Collections.emptyList();
        if (StringUtils.hasText(keyword)) {
            matchedUserIds = userMapper.selectList(
                    new LambdaQueryWrapper<DsUser>()
                            .select(DsUser::getUserId)
                            .and(w -> w.like(DsUser::getNickname, keyword).or().like(DsUser::getPhone, keyword))
            ).stream().map(DsUser::getUserId).collect(Collectors.toList());

            List<Long> finalMatchedUserIds = matchedUserIds;
            wrapper.and(w -> w.like(DsAddress::getReceiverName, keyword)
                    .or().like(DsAddress::getPhone, keyword)
                    .or().like(DsAddress::getDetailAddress, keyword)
                    .or(inner -> {
                        if (!finalMatchedUserIds.isEmpty()) {
                            inner.in(DsAddress::getUserId, finalMatchedUserIds);
                        } else {
                            inner.eq(DsAddress::getAddressId, -1L);
                        }
                    }));
        }

        wrapper.orderByDesc(DsAddress::getCreateTime);
        IPage<DsAddress> page = addressMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);

        Set<Long> userIds = page.getRecords().stream().map(DsAddress::getUserId).collect(Collectors.toSet());
        Map<Long, DsUser> userMap = userIds.isEmpty()
                ? Collections.emptyMap()
                : userMapper.selectList(new LambdaQueryWrapper<DsUser>().in(DsUser::getUserId, userIds))
                .stream()
                .collect(Collectors.toMap(DsUser::getUserId, Function.identity()));

        List<CustomerAddressVO> records = page.getRecords().stream().map(address -> {
            DsUser user = userMap.get(address.getUserId());
            CustomerAddressVO vo = new CustomerAddressVO();
            vo.setAddressId(address.getAddressId());
            vo.setUserId(address.getUserId());
            vo.setNickname(user != null ? user.getNickname() : null);
            vo.setUserPhone(user != null ? user.getPhone() : null);
            vo.setReceiverName(address.getReceiverName());
            vo.setPhone(address.getPhone());
            vo.setProvince(address.getProvince());
            vo.setCity(address.getCity());
            vo.setDistrict(address.getDistrict());
            vo.setDetailAddress(address.getDetailAddress());
            vo.setDefault(address.getIsDefault());
            vo.setCreateTime(address.getCreateTime());
            return vo;
        }).collect(Collectors.toList());

        return R.ok(PageResult.of(records, page.getTotal(), page.getCurrent(), page.getSize()));
    }

    private Map<Long, List<DsAddress>> loadAddressesByUserIds(List<Long> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            return Collections.emptyMap();
        }
        return addressMapper.selectList(
                new LambdaQueryWrapper<DsAddress>()
                        .in(DsAddress::getUserId, userIds)
                        .orderByDesc(DsAddress::getIsDefault)
                        .orderByDesc(DsAddress::getCreateTime)
        ).stream().collect(Collectors.groupingBy(DsAddress::getUserId));
    }

    private String formatDefaultAddress(List<DsAddress> addresses) {
        if (addresses == null || addresses.isEmpty()) {
            return null;
        }
        DsAddress address = addresses.stream()
                .filter(item -> Boolean.TRUE.equals(item.getIsDefault()))
                .findFirst()
                .orElse(addresses.get(0));
        return joinAddress(address.getProvince(), address.getCity(), address.getDistrict(), address.getDetailAddress());
    }

    private String joinAddress(String province, String city, String district, String detailAddress) {
        return List.of(
                        province == null ? "" : province,
                        city == null ? "" : city,
                        district == null ? "" : district,
                        detailAddress == null ? "" : detailAddress
                ).stream()
                .filter(StringUtils::hasText)
                .collect(Collectors.joining(" "));
    }

    @Data
    public static class CustomerListVO {
        private Long userId;
        private String nickname;
        private String avatarUrl;
        private String phone;
        private Integer status;
        private java.time.LocalDateTime lastLoginTime;
        private java.time.LocalDateTime createTime;
        private Integer addressCount;
        private String defaultAddress;
    }

    @Data
    public static class CustomerAddressVO {
        private Long addressId;
        private Long userId;
        private String nickname;
        private String userPhone;
        private String receiverName;
        private String phone;
        private String province;
        private String city;
        private String district;
        private String detailAddress;
        private Boolean isDefault;
        private java.time.LocalDateTime createTime;

        public void setDefault(Boolean aDefault) {
            isDefault = aDefault;
        }
    }
}
