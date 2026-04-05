package com.designstudio.common.annotation;

import java.lang.annotation.*;

/**
 * 操作日志注解 - 标注在 Controller 方法上，自动记录操作日志
 *
 * 用法: @OperLog("创建订单")
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface OperLog {
    /** 操作模块/标题 */
    String value() default "";
}
