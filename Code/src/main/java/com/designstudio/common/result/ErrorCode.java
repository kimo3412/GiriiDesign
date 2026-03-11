package com.designstudio.common.result;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 统一错误码枚举
 * <p>
 * 格式：XXYYY
 * XX - 模块代码 (10=系统, 20=用户, 30=订单, 40=支付, 50=物料)
 * YYY - 具体错误序号
 */
@Getter
@AllArgsConstructor
public enum ErrorCode {

    // ==================== 系统级 ====================
    SUCCESS(200, "操作成功"),
    SYSTEM_ERROR(10001, "服务内部错误，请稍后重试"),
    PARAM_ERROR(10002, "参数校验失败"),
    RATE_LIMIT(10003, "请求频率超限"),

    // ==================== 用户/鉴权 ====================
    TOKEN_INVALID(20001, "登录已过期，请重新登录"),
    NO_PERMISSION(20002, "您没有权限执行此操作"),
    ACCOUNT_DISABLED(20003, "账号已被禁用"),
    USERNAME_PASSWORD_ERROR(20004, "用户名或密码错误"),
    WX_LOGIN_FAIL(20005, "微信登录失败"),

    // ==================== 订单 ====================
    REQUEST_NOT_FOUND(30001, "意向不存在"),
    ORDER_STATUS_ERROR(30002, "当前订单状态不允许此操作"),
    WORKFLOW_TRANSITION_ERROR(30003, "不能跳过生产流程节点"),
    ORDER_NOT_FOUND(30004, "订单不存在"),

    // ==================== 支付 ====================
    PAYMENT_CREATE_FAIL(40001, "支付单创建失败"),
    PAYMENT_EXPIRED(40002, "支付已过期"),
    REFUND_AMOUNT_EXCEED(40003, "退款金额超过可退金额"),

    // ==================== 物料 ====================
    STOCK_NOT_ENOUGH(50001, "库存不足，请联系管理员");

    private final int code;
    private final String msg;
}
