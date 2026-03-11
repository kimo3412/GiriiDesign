package com.designstudio.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.system.domain.SysRole;
import com.designstudio.system.domain.SysRoleMenu;
import com.designstudio.system.mapper.SysRoleMapper;
import com.designstudio.system.mapper.SysRoleMenuMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 角色管理
 */
@RestController
@RequestMapping("/api/v1/admin/roles")
@RequiredArgsConstructor
@Tag(name = "角色管理")
public class SysRoleController {

    private final SysRoleMapper roleMapper;
    private final SysRoleMenuMapper roleMenuMapper;

    @GetMapping
    @Operation(summary = "获取角色列表")
    public R<List<SysRole>> list() {
        return R.ok(roleMapper.selectList(new LambdaQueryWrapper<SysRole>().orderByDesc(SysRole::getCreateTime)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取角色及权限菜单")
    public R<RoleDetailVO> get(@PathVariable Long id) {
        SysRole role = roleMapper.selectById(id);
        List<SysRoleMenu> roleMenus = roleMenuMapper.selectList(
                new LambdaQueryWrapper<SysRoleMenu>().eq(SysRoleMenu::getRoleId, id));
        List<Long> menuIds = roleMenus.stream().map(SysRoleMenu::getMenuId).collect(Collectors.toList());

        RoleDetailVO vo = new RoleDetailVO();
        vo.setRole(role);
        vo.setMenuIds(menuIds);
        return R.ok(vo);
    }

    @PostMapping
    @Operation(summary = "新增角色")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> add(@RequestBody RoleSaveDTO dto) {
        SysRole exist = roleMapper.selectOne(new LambdaQueryWrapper<SysRole>().eq(SysRole::getRoleKey, dto.getRoleKey()));
        if (exist != null) {
            return R.fail("角色标识已被占用");
        }

        SysRole role = new SysRole();
        role.setRoleName(dto.getRoleName());
        role.setRoleKey(dto.getRoleKey());
        role.setRemark(dto.getRemark());
        roleMapper.insert(role);

        if (dto.getMenuIds() != null && !dto.getMenuIds().isEmpty()) {
            for (Long menuId : dto.getMenuIds()) {
                roleMenuMapper.insert(new SysRoleMenu(role.getRoleId(), menuId));
            }
        }
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改角色")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> update(@PathVariable Long id, @RequestBody RoleSaveDTO dto) {
        SysRole role = roleMapper.selectById(id);
        if (role == null) {
            return R.fail("角色不存在");
        }

        if (!role.getRoleKey().equals(dto.getRoleKey())) {
            SysRole exist = roleMapper.selectOne(new LambdaQueryWrapper<SysRole>().eq(SysRole::getRoleKey, dto.getRoleKey()));
            if (exist != null) {
                return R.fail("角色标识已被占用");
            }
        }

        role.setRoleName(dto.getRoleName());
        role.setRoleKey(dto.getRoleKey());
        role.setRemark(dto.getRemark());
        roleMapper.updateById(role);

        roleMenuMapper.delete(new LambdaQueryWrapper<SysRoleMenu>().eq(SysRoleMenu::getRoleId, id));
        if (dto.getMenuIds() != null && !dto.getMenuIds().isEmpty()) {
            for (Long menuId : dto.getMenuIds()) {
                roleMenuMapper.insert(new SysRoleMenu(id, menuId));
            }
        }
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除角色")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> delete(@PathVariable Long id) {
        if (id == 1L || id == 2L) {
            return R.fail("内置角色不可删除");
        }
        roleMapper.deleteById(id);
        roleMenuMapper.delete(new LambdaQueryWrapper<SysRoleMenu>().eq(SysRoleMenu::getRoleId, id));
        return R.ok();
    }

    @Data
    public static class RoleSaveDTO {
        private String roleName;
        private String roleKey;
        private String remark;
        private List<Long> menuIds;
    }

    @Data
    public static class RoleDetailVO {
        private SysRole role;
        private List<Long> menuIds;
    }
}
