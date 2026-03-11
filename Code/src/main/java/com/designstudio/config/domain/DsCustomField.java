package com.designstudio.config.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 动态字段定义实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_custom_field")
public class DsCustomField extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long fieldId;

    /** 所属品类ID */
    private Long categoryId;

    /** 字段显示名 */
    private String label;

    /** 字段键名 */
    private String fieldKey;

    /** 控件类型: text/number/select/date/image */
    private String fieldType;

    /** 单位 */
    private String unit;

    /** 选项列表(JSON字符串) */
    private String options;

    /** 输入提示 */
    private String placeholder;

    /** 是否必填 */
    private Integer isRequired;

    /** 排序 */
    private Integer sortOrder;
}
