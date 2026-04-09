package com.designstudio.system.domain;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * 设计师-品类关联（多对多）
 */
@Data
@TableName("ds_designer_category")
public class DsDesignerCategory {

    private Long adminId;

    private Long categoryId;
}
