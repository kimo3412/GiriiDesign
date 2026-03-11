package com.designstudio.system.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;

/**
 * 字典类型实体
 */
@Data
@TableName("sys_dict_type")
public class SysDictType implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long dictId;

    /** 字典名称 */
    private String dictName;

    /** 字典类型标识 */
    private String dictType;

    /** 备注 */
    private String remark;

    /** 逻辑删除 */
    private Integer delFlag;
}
