package com.designstudio.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.system.domain.SysOperLog;
import com.designstudio.system.mapper.SysOperLogMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 操作日志 Controller
 */
@RestController
@RequestMapping("/api/v1/admin/logs")
@RequiredArgsConstructor
@Tag(name = "操作日志")
public class SysOperLogController {

    private final SysOperLogMapper logMapper;

    @GetMapping
    @Operation(summary = "查询操作日志列表")
    public R<List<SysOperLog>> list(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String operatorName,
            @RequestParam(required = false) Integer status) {

        LambdaQueryWrapper<SysOperLog> wrapper = new LambdaQueryWrapper<>();
        if (title != null && !title.isEmpty()) {
            wrapper.like(SysOperLog::getTitle, title);
        }
        if (operatorName != null && !operatorName.isEmpty()) {
            wrapper.like(SysOperLog::getOperatorName, operatorName);
        }
        if (status != null) {
            wrapper.eq(SysOperLog::getStatus, status);
        }
        wrapper.orderByDesc(SysOperLog::getOperTime);
        // 限制最多返回 500 条
        wrapper.last("LIMIT 500");
        return R.ok(logMapper.selectList(wrapper));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除操作日志")
    public R<Void> delete(@PathVariable Long id) {
        logMapper.deleteById(id);
        return R.ok();
    }

    @DeleteMapping("/clean")
    @Operation(summary = "清空操作日志")
    public R<Void> clean() {
        logMapper.delete(null);
        return R.ok();
    }
}
