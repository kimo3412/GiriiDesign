package com.designstudio.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.designstudio.system.controller.SysAdminController;
import com.designstudio.system.domain.SysAdmin;
import com.designstudio.system.domain.SysAdminRole;
import com.designstudio.system.mapper.SysAdminMapper;
import com.designstudio.system.mapper.SysAdminRoleMapper;
import com.designstudio.system.service.ISysAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 后台用户 Service 实现
 */
@Service
@RequiredArgsConstructor
public class SysAdminServiceImpl extends ServiceImpl<SysAdminMapper, SysAdmin> implements ISysAdminService {

    private final SysAdminRoleMapper adminRoleMapper;
    private final PasswordEncoder passwordEncoder;

    @Override
    public SysAdmin getByUsername(String username) {
        return getOne(new LambdaQueryWrapper<SysAdmin>()
                .eq(SysAdmin::getUsername, username)
                .eq(SysAdmin::getDelFlag, 0));
    }

    @Override
    public List<SysAdmin> listAdmins() {
        List<SysAdmin> list = list(new LambdaQueryWrapper<SysAdmin>().orderByDesc(SysAdmin::getCreateTime));
        list.forEach(a -> a.setPassword(null));
        return list;
    }

    @Override
    public SysAdminController.AdminDetailVO getAdminDetail(Long id) {
        SysAdmin admin = getById(id);
        if (admin != null) {
            admin.setPassword(null);
        }

        List<SysAdminRole> adminRoles = adminRoleMapper.selectList(
                new LambdaQueryWrapper<SysAdminRole>().eq(SysAdminRole::getAdminId, id));
        List<Long> roleIds = adminRoles.stream().map(SysAdminRole::getRoleId).collect(Collectors.toList());

        SysAdminController.AdminDetailVO vo = new SysAdminController.AdminDetailVO();
        vo.setAdmin(admin);
        vo.setRoleIds(roleIds);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addAdmin(SysAdminController.AdminSaveDTO dto) {
        SysAdmin exist = getOne(new LambdaQueryWrapper<SysAdmin>().eq(SysAdmin::getUsername, dto.getUsername()));
        if (exist != null) {
            throw new RuntimeException("用户名已被占用");
        }

        SysAdmin admin = new SysAdmin();
        admin.setUsername(dto.getUsername());
        admin.setNickname(dto.getNickname());
        admin.setPhone(dto.getPhone());
        admin.setEmail(dto.getEmail());
        admin.setStatus(dto.getStatus());

        String pwd = StringUtils.hasText(dto.getPassword()) ? dto.getPassword() : "123456";
        admin.setPassword(passwordEncoder.encode(pwd));

        save(admin);

        if (dto.getRoleIds() != null && !dto.getRoleIds().isEmpty()) {
            for (Long roleId : dto.getRoleIds()) {
                adminRoleMapper.insert(new SysAdminRole(admin.getAdminId(), roleId));
            }
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateAdmin(Long id, SysAdminController.AdminSaveDTO dto) {
        SysAdmin admin = getById(id);
        if (admin == null) throw new RuntimeException("用户不存在");

        if (!admin.getUsername().equals(dto.getUsername())) {
            SysAdmin exist = getOne(new LambdaQueryWrapper<SysAdmin>().eq(SysAdmin::getUsername, dto.getUsername()));
            if (exist != null) throw new RuntimeException("用户名已被占用");
        }

        admin.setUsername(dto.getUsername());
        admin.setNickname(dto.getNickname());
        admin.setPhone(dto.getPhone());
        admin.setEmail(dto.getEmail());
        admin.setStatus(dto.getStatus());

        if (StringUtils.hasText(dto.getPassword())) {
            admin.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        updateById(admin);

        adminRoleMapper.delete(new LambdaQueryWrapper<SysAdminRole>().eq(SysAdminRole::getAdminId, id));
        if (dto.getRoleIds() != null && !dto.getRoleIds().isEmpty()) {
            for (Long roleId : dto.getRoleIds()) {
                adminRoleMapper.insert(new SysAdminRole(id, roleId));
            }
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteAdmin(Long id) {
        if (id == 1L) throw new RuntimeException("超级管理员不可删除");
        removeById(id);
        adminRoleMapper.delete(new LambdaQueryWrapper<SysAdminRole>().eq(SysAdminRole::getAdminId, id));
    }
}
