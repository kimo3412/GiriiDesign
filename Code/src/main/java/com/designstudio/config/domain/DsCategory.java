package com.designstudio.config.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 品类实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_category")
public class DsCategory extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long categoryId;

    /** 品类名称 */
    private String name;

    /** 图标URL */
    private String iconUrl;

    /** 是否启用 */
    private Integer isActive;

    /** 是否需要BOM */
    private Integer hasBom;

    /** 是否实体产品 */
    private Integer isPhysical;

    /** 排序 */
    private Integer sortOrder;
}
