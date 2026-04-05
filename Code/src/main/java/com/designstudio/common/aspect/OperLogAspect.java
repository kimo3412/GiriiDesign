package com.designstudio.common.aspect;

import cn.hutool.json.JSONUtil;
import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.common.security.LoginUser;
import com.designstudio.system.domain.SysOperLog;
import com.designstudio.system.mapper.SysOperLogMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;

/**
 * 操作日志 AOP 切面
 * 拦截所有标注了 @OperLog 的方法，自动记录到 sys_oper_log 表
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class OperLogAspect {

    private final SysOperLogMapper logMapper;

    @Around("@annotation(operLog)")
    public Object around(ProceedingJoinPoint joinPoint, OperLog operLog) throws Throwable {
        SysOperLog sysLog = new SysOperLog();
        sysLog.setTitle(operLog.value());
        sysLog.setOperTime(LocalDateTime.now());

        // 方法签名
        MethodSignature sig = (MethodSignature) joinPoint.getSignature();
        sysLog.setMethod(sig.getDeclaringTypeName() + "." + sig.getName());

        // 请求信息
        try {
            ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                HttpServletRequest request = attrs.getRequest();
                sysLog.setRequestMethod(request.getMethod());
                sysLog.setOperUrl(request.getRequestURI());
                sysLog.setOperIp(getClientIp(request));
            }
        } catch (Exception ignored) {}

        // 操作人
        try {
            LoginUser loginUser = LoginHelper.getLoginUser();
            if (loginUser != null) {
                sysLog.setOperatorId(loginUser.getAdminId());
                sysLog.setOperatorName(loginUser.getUsername());
            }
        } catch (Exception ignored) {}

        // 请求参数（截取前 2000 字符）
        try {
            Object[] args = joinPoint.getArgs();
            if (args != null && args.length > 0) {
                String params = JSONUtil.toJsonStr(args);
                sysLog.setOperParam(params.length() > 2000 ? params.substring(0, 2000) : params);
            }
        } catch (Exception ignored) {}

        // 执行目标方法
        Object result;
        try {
            result = joinPoint.proceed();
            sysLog.setStatus(0); // 成功

            // 返回结果（截取前 2000 字符）
            try {
                String resultStr = JSONUtil.toJsonStr(result);
                sysLog.setJsonResult(resultStr.length() > 2000 ? resultStr.substring(0, 2000) : resultStr);
            } catch (Exception ignored) {}

        } catch (Throwable ex) {
            sysLog.setStatus(1); // 异常
            sysLog.setErrorMsg(ex.getMessage() != null
                    ? (ex.getMessage().length() > 2000 ? ex.getMessage().substring(0, 2000) : ex.getMessage())
                    : ex.getClass().getSimpleName());
            throw ex;
        } finally {
            // 异步写入日志（不阻塞主流程）
            try {
                logMapper.insert(sysLog);
            } catch (Exception e) {
                log.error("操作日志写入失败", e);
            }
        }

        return result;
    }

    /**
     * 获取客户端 IP
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // 多个代理时取第一个
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
