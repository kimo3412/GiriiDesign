package com.designstudio.system.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 菜单/权限实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_menu")
public class SysMenu extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long menuId;

    /** 父菜单ID（0=顶级） */
    private Long parentId;

    /** 菜单名称 */
    private String menuName;

    /** 菜单类型（M=目录, C=菜单, F=按钮） */
    private String menuType;

    /** 路由地址 */
    private String path;

    /** 组件路径 */
    private String component;

    /** 权限标识（如 order:list） */
    private String perms;

    /** 图标 */
    private String icon;

    /** 排序 */
    private Integer sortOrder;

    /** 是否可见 */
    private Integer visible;
}
