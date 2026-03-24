package com.designstudio.customer.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * C端用户表（小程序客户）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_user")
public class DsUser extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long userId;

    /** 微信openid */
    private String openid;

    /** 用户昵称 */
    private String nickname;

    /** 头像 */
    private String avatarUrl;

    /** 手机号 */
    private String phone;

    /** 0=禁用,1=正常 */
    private Integer status;

    /** 最后登录时间 */
    private LocalDateTime lastLoginTime;
}
