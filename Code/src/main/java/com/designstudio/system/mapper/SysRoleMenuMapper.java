package com.designstudio.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.system.domain.SysRoleMenu;
import org.apache.ibatis.annotations.Mapper;

/**
 * 角色菜单关联 Mapper
 */
@Mapper
public interface SysRoleMenuMapper extends BaseMapper<SysRoleMenu> {
}
