package com.designstudio.system.controller;

import com.designstudio.common.annotation.OperLog;
import com.designstudio.common.result.R;
import com.designstudio.system.domain.SysRole;
import com.designstudio.system.service.ISysRoleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 角色管理
 */
@RestController
@RequestMapping("/api/v1/admin/roles")
@RequiredArgsConstructor
@Tag(name = "角色管理")
public class SysRoleController {

    private final ISysRoleService roleService;

    @GetMapping
    @Operation(summary = "获取角色列表")
    public R<List<SysRole>> list() {
        return R.ok(roleService.listRoles());
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取角色及权限菜单")
    public R<RoleDetailVO> get(@PathVariable Long id) {
        return R.ok(roleService.getRoleDetail(id));
    }

    @PostMapping
    @Operation(summary = "新增角色")
    @OperLog("新增角色")
    public R<Void> add(@RequestBody RoleSaveDTO dto) {
        try {
            roleService.addRole(dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改角色")
    @OperLog("修改角色")
    public R<Void> update(@PathVariable Long id, @RequestBody RoleSaveDTO dto) {
        try {
            roleService.updateRole(id, dto);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除角色")
    @OperLog("删除角色")
    public R<Void> delete(@PathVariable Long id) {
        try {
            roleService.deleteRole(id);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    @Data
    public static class RoleSaveDTO {
        private String roleName;
        private String roleKey;
        private String roleType;
        private String remark;
        private List<Long> menuIds;
    }

    @Data
    public static class RoleDetailVO {
        private SysRole role;
        private List<Long> menuIds;
    }
}
