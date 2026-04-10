package com.designstudio.system.controller;

import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.system.domain.SysAdmin;
import com.designstudio.system.service.ISysAdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户管理
 */
@RestController
@RequestMapping("/api/v1/admin/users")
@RequiredArgsConstructor
@Tag(name = "后台用户管理")
public class SysAdminController {

    private final ISysAdminService adminService;

    @GetMapping
    @Operation(summary = "获取用户列表")
    public R<List<SysAdmin>> list() {
        return R.ok(adminService.listAdmins());
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取单个用户及角色详情")
    public R<AdminDetailVO> get(@PathVariable Long id) {
        return R.ok(adminService.getAdminDetail(id));
    }

    @PostMapping
    @Operation(summary = "新增用户")
    @OperLog("新增后台用户")
    public R<Void> add(@RequestBody AdminSaveDTO dto) {
        try {
            adminService.addAdmin(dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "编辑用户")
    @OperLog("编辑后台用户")
    public R<Void> update(@PathVariable Long id, @RequestBody AdminSaveDTO dto) {
        try {
            adminService.updateAdmin(id, dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除用户")
    @OperLog("删除后台用户")
    public R<Void> delete(@PathVariable Long id) {
        try {
            adminService.deleteAdmin(id);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @DeleteMapping("/batch")
    @Operation(summary = "批量删除用户")
    @OperLog("批量删除后台用户")
    public R<Void> batchDelete(@RequestBody List<Long> ids) {
        try {
            for (Long id : ids) {
                adminService.deleteAdmin(id);
            }
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PutMapping("/{id}/categories")
    @Operation(summary = "设置设计师负责的品类")
    @OperLog("设置设计师品类")
    public R<Void> updateCategories(@PathVariable Long id, @RequestBody List<Long> categoryIds) {
        adminService.updateDesignerCategories(id, categoryIds);
        return R.ok();
    }

    @Data
    public static class AdminSaveDTO {
        private String username;
        private String password;
        private String nickname;
        private String phone;
        private String email;
        private Integer status;
        private List<Long> roleIds;
    }

    @Data
    public static class AdminDetailVO {
        private SysAdmin admin;
        private List<Long> roleIds;
        private List<Long> categoryIds;
    }
}
