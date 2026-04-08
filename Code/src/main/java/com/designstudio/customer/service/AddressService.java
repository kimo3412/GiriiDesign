package com.designstudio.customer.service;

import com.designstudio.customer.domain.DsAddress;

import java.util.List;

/**
 * 地址业务 Service
 */
public interface AddressService {

    List<DsAddress> listAddresses(Long userId);

    void addAddress(Long userId, DsAddress address);

    void updateAddress(Long userId, Long addressId, DsAddress address);

    void deleteAddress(Long userId, Long addressId);

    void setDefault(Long userId, Long addressId);
}
