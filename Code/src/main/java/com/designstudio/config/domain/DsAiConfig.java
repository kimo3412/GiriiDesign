package com.designstudio.config.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.designstudio.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * AI customer service configuration entity.
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ds_ai_config")
public class DsAiConfig extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long configId;

    private String providerName;

    private Integer enabled;

    private String apiUrl;

    private String apiKey;

    private String model;

    private String systemPrompt;
}
