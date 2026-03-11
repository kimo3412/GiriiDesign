package com.designstudio.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.system.domain.SysAdmin;
import com.designstudio.system.domain.SysAdminRole;
import com.designstudio.system.mapper.SysAdminMapper;
import com.designstudio.system.mapper.SysAdminRoleMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 用户管理
 */
@RestController
@RequestMapping("/api/v1/admin/users")
@RequiredArgsConstructor
@Tag(name = "后台用户管理")
public class SysAdminController {

    private final SysAdminMapper adminMapper;
    private final SysAdminRoleMapper adminRoleMapper;
    private final PasswordEncoder passwordEncoder;

    @GetMapping
    @Operation(summary = "获取用户列表")
    public R<List<SysAdmin>> list() {
        List<SysAdmin> list = adminMapper.selectList(new LambdaQueryWrapper<SysAdmin>().orderByDesc(SysAdmin::getCreateTime));
        // 出于安全考虑，清除密码
        list.forEach(a -> a.setPassword(null));
        return R.ok(list);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取单个用户及角色详情")
    public R<AdminDetailVO> get(@PathVariable Long id) {
        SysAdmin admin = adminMapper.selectById(id);
        if (admin != null) {
            admin.setPassword(null);
        }
        
        List<SysAdminRole> adminRoles = adminRoleMapper.selectList(
                new LambdaQueryWrapper<SysAdminRole>().eq(SysAdminRole::getAdminId, id));
        List<Long> roleIds = adminRoles.stream().map(SysAdminRole::getRoleId).collect(Collectors.toList());

        AdminDetailVO vo = new AdminDetailVO();
        vo.setAdmin(admin);
        vo.setRoleIds(roleIds);
        return R.ok(vo);
    }

    @PostMapping
    @Operation(summary = "新增用户")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> add(@RequestBody AdminSaveDTO dto) {
        // 检查用户名是否存在
        SysAdmin exist = adminMapper.selectOne(new LambdaQueryWrapper<SysAdmin>().eq(SysAdmin::getUsername, dto.getUsername()));
        if (exist != null) {
            return R.fail("用户名已被占用");
        }

        SysAdmin admin = new SysAdmin();
        admin.setUsername(dto.getUsername());
        admin.setNickname(dto.getNickname());
        admin.setPhone(dto.getPhone());
        admin.setEmail(dto.getEmail());
        admin.setStatus(dto.getStatus());
        
        // 默认密码或传入密码
        String pwd = StringUtils.hasText(dto.getPassword()) ? dto.getPassword() : "123456";
        admin.setPassword(passwordEncoder.encode(pwd));
        
        adminMapper.insert(admin);

        // 如果有角色，分配角色
        if (dto.getRoleIds() != null && !dto.getRoleIds().isEmpty()) {
            for (Long roleId : dto.getRoleIds()) {
                adminRoleMapper.insert(new SysAdminRole(admin.getAdminId(), roleId));
            }
        }
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "编辑用户")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> update(@PathVariable Long id, @RequestBody AdminSaveDTO dto) {
        SysAdmin admin = adminMapper.selectById(id);
        if (admin == null) {
            return R.fail("用户不存在");
        }

        // 如果修改了用户名，需查重
        if (!admin.getUsername().equals(dto.getUsername())) {
            SysAdmin exist = adminMapper.selectOne(new LambdaQueryWrapper<SysAdmin>().eq(SysAdmin::getUsername, dto.getUsername()));
            if (exist != null) {
                return R.fail("用户名已被占用");
            }
        }

        admin.setUsername(dto.getUsername());
        admin.setNickname(dto.getNickname());
        admin.setPhone(dto.getPhone());
        admin.setEmail(dto.getEmail());
        admin.setStatus(dto.getStatus());

        // 修改了密码
        if (StringUtils.hasText(dto.getPassword())) {
            admin.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        adminMapper.updateById(admin);

        // 先清理角色
        adminRoleMapper.delete(new LambdaQueryWrapper<SysAdminRole>().eq(SysAdminRole::getAdminId, id));
        // 重新赋予角色
        if (dto.getRoleIds() != null && !dto.getRoleIds().isEmpty()) {
            for (Long roleId : dto.getRoleIds()) {
                adminRoleMapper.insert(new SysAdminRole(id, roleId));
            }
        }
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除用户")
    @Transactional(rollbackFor = Exception.class)
    public R<Void> delete(@PathVariable Long id) {
        if (id == 1L) {
            return R.fail("超级管理员不可删除");
        }
        adminMapper.deleteById(id);
        adminRoleMapper.delete(new LambdaQueryWrapper<SysAdminRole>().eq(SysAdminRole::getAdminId, id));
        return R.ok();
    }

    @Data
    public static class AdminSaveDTO {
        private String username;
        private String password; // 若修改则传，否则可为空
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
    }
}
