package com.designstudio.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.system.domain.SysRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 角色 Mapper
 */
@Mapper
public interface SysRoleMapper extends BaseMapper<SysRole> {

    /**
     * 根据用户ID查询角色列表
     */
    @Select("SELECT r.* FROM sys_role r " +
            "INNER JOIN sys_admin_role ar ON r.role_id = ar.role_id " +
            "WHERE ar.admin_id = #{adminId} AND r.del_flag = 0")
    List<SysRole> selectRolesByAdminId(@Param("adminId") Long adminId);

    /**
     * 根据用户ID查询角色标识列表
     */
    @Select("SELECT r.role_key FROM sys_role r " +
            "INNER JOIN sys_admin_role ar ON r.role_id = ar.role_id " +
            "WHERE ar.admin_id = #{adminId} AND r.del_flag = 0")
    List<String> selectRoleKeysByAdminId(@Param("adminId") Long adminId);
}
