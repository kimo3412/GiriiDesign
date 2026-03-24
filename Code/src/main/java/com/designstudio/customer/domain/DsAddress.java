package com.designstudio.customer.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 客户收货地址表 ds_address
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_address")
public class DsAddress extends BaseEntity {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long addressId;

    private Long userId;

    private String receiverName;

    private String phone;

    private String province;

    private String city;

    private String district;

    private String detailAddress;

    private Boolean isDefault;

    private Integer delFlag;
}
