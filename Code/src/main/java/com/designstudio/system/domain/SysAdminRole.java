package com.designstudio.system.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * 用户角色关联实体
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("sys_admin_role")
public class SysAdminRole implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 用户ID */
    @TableId
    private Long adminId;

    /** 角色ID */
    private Long roleId;
}
