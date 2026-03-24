package com.designstudio.portfolio.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

/**
 * 作品集主表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName(value = "ds_portfolio", autoResultMap = true)
public class DsPortfolio extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long portfolioId;

    /** 作品标题 */
    private String title;

    /** 关联品类 */
    private Long categoryId;

    /** 封面图 */
    private String coverUrl;

    /** 图片列表(JSON数组) */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> imageUrls;

    /** 富文本描述 */
    private String description;

    /** 状态 0=草稿,1=发布 */
    private Integer status;

    /** 浏览次数 */
    private Integer viewCount;

    /** 排序 */
    private Integer sortOrder;
}
