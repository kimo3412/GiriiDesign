package com.designstudio.config.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 小程序轮播图实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_banner")
public class DsBanner extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long bannerId;

    /** 轮播图标题 */
    private String title;

    /** 图片地址 */
    private String imageUrl;

    /** 跳转链接 */
    private String linkUrl;

    /** 跳转类型：portfolio/order/custom/null */
    private String linkType;

    /** 排序 */
    private Integer sortOrder;

    /** 状态：0禁用 1启用 */
    private Integer status;
}
