package com.designstudio.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.designstudio.system.domain.SysAdminRole;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 用户角色关联 Mapper
 */
@Mapper
public interface SysAdminRoleMapper extends BaseMapper<SysAdminRole> {

    /**
     * 根据用户ID删除关联
     */
    @Delete("DELETE FROM sys_admin_role WHERE admin_id = #{adminId}")
    int deleteByAdminId(@Param("adminId") Long adminId);
}
