package com.designstudio.system.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;

/**
 * 字典数据实体
 */
@Data
@TableName("sys_dict_data")
public class SysDictData implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long dictCode;

    /** 字典类型标识 */
    private String dictType;

    /** 字典标签 */
    private String dictLabel;

    /** 字典值 */
    private String dictValue;

    /** 排序 */
    private Integer sortOrder;

    /** 备注 */
    private String remark;

    /** 逻辑删除 */
    private Integer delFlag;
}
