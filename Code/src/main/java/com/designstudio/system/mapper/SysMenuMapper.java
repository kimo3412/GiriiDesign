package com.designstudio.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.system.domain.SysMenu;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 菜单 Mapper
 */
@Mapper
public interface SysMenuMapper extends BaseMapper<SysMenu> {

    /**
     * 根据角色ID查询权限标识列表
     */
    @Select("SELECT DISTINCT m.perms FROM sys_menu m " +
            "INNER JOIN sys_role_menu rm ON m.menu_id = rm.menu_id " +
            "WHERE rm.role_id = #{roleId} AND m.perms IS NOT NULL AND m.perms != '' AND m.del_flag = 0")
    List<String> selectPermsByRoleId(@Param("roleId") Long roleId);

    /**
     * 根据用户ID查询权限标识列表
     */
    @Select("SELECT DISTINCT m.perms FROM sys_menu m " +
            "INNER JOIN sys_role_menu rm ON m.menu_id = rm.menu_id " +
            "INNER JOIN sys_admin_role ar ON rm.role_id = ar.role_id " +
            "WHERE ar.admin_id = #{adminId} AND m.perms IS NOT NULL AND m.perms != '' AND m.del_flag = 0")
    List<String> selectPermsByAdminId(@Param("adminId") Long adminId);

    /**
     * 根据用户ID查询菜单树
     */
    @Select("SELECT DISTINCT m.* FROM sys_menu m " +
            "INNER JOIN sys_role_menu rm ON m.menu_id = rm.menu_id " +
            "INNER JOIN sys_admin_role ar ON rm.role_id = ar.role_id " +
            "WHERE ar.admin_id = #{adminId} AND m.del_flag = 0 " +
            "ORDER BY m.sort_order")
    List<SysMenu> selectMenusByAdminId(@Param("adminId") Long adminId);
}
