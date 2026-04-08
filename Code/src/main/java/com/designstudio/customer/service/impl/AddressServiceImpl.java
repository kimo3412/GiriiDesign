package com.designstudio.customer.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.customer.domain.DsAddress;
import com.designstudio.customer.mapper.DsAddressMapper;
import com.designstudio.customer.service.AddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 地址业务 Service 实现
 */
@Service
@RequiredArgsConstructor
public class AddressServiceImpl implements AddressService {

    private final DsAddressMapper addressMapper;

    @Override
    public List<DsAddress> listAddresses(Long userId) {
        return addressMapper.selectList(
                new LambdaQueryWrapper<DsAddress>()
                        .eq(DsAddress::getUserId, userId)
                        .orderByDesc(DsAddress::getIsDefault)
                        .orderByDesc(DsAddress::getCreateTime));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addAddress(Long userId, DsAddress address) {
        address.setUserId(userId);
        handleDefaultLogic(userId, address);
        addressMapper.insert(address);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateAddress(Long userId, Long addressId, DsAddress address) {
        address.setAddressId(addressId);
        address.setUserId(userId);
        handleDefaultLogic(userId, address);
        addressMapper.updateById(address);
    }

    @Override
    public void deleteAddress(Long userId, Long addressId) {
        addressMapper.delete(new LambdaQueryWrapper<DsAddress>()
                .eq(DsAddress::getAddressId, addressId)
                .eq(DsAddress::getUserId, userId));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void setDefault(Long userId, Long addressId) {
        DsAddress address = new DsAddress();
        address.setAddressId(addressId);
        address.setUserId(userId);
        address.setIsDefault(true);
        handleDefaultLogic(userId, address);
        addressMapper.updateById(address);
    }

    private void handleDefaultLogic(Long userId, DsAddress address) {
        if (Boolean.TRUE.equals(address.getIsDefault())) {
            DsAddress updateObj = new DsAddress();
            updateObj.setIsDefault(false);
            addressMapper.update(updateObj, new LambdaQueryWrapper<DsAddress>()
                    .eq(DsAddress::getUserId, userId));
        } else {
            Long count = addressMapper.selectCount(new LambdaQueryWrapper<DsAddress>()
                    .eq(DsAddress::getUserId, userId));
            if (count == 0) {
                address.setIsDefault(true);
            }
        }
    }
}
