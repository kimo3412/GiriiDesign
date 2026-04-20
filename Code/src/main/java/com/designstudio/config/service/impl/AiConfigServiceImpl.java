package com.designstudio.config.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.config.domain.DsAiConfig;
import com.designstudio.config.mapper.DsAiConfigMapper;
import com.designstudio.config.service.AiConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

/**
 * AI config service implementation.
 */
@Service
@RequiredArgsConstructor
public class AiConfigServiceImpl implements AiConfigService {

    private final DsAiConfigMapper aiConfigMapper;

    @Value("${ai.customer-service.enabled:false}")
    private boolean defaultEnabled;

    @Value("${ai.customer-service.api-url:}")
    private String defaultApiUrl;

    @Value("${ai.customer-service.api-key:}")
    private String defaultApiKey;

    @Value("${ai.customer-service.model:}")
    private String defaultModel;

    @Value("${ai.customer-service.system-prompt:}")
    private String defaultSystemPrompt;

    @Override
    public DsAiConfig getConfig() {
        DsAiConfig config = aiConfigMapper.selectOne(
                new LambdaQueryWrapper<DsAiConfig>()
                        .orderByDesc(DsAiConfig::getConfigId)
                        .last("LIMIT 1")
        );
        if (config != null) {
            return config;
        }
        return buildDefaultConfig();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DsAiConfig saveConfig(DsAiConfig config) {
        DsAiConfig existing = aiConfigMapper.selectOne(
                new LambdaQueryWrapper<DsAiConfig>()
                        .orderByDesc(DsAiConfig::getConfigId)
                        .last("LIMIT 1")
        );

        if (existing == null) {
            DsAiConfig entity = new DsAiConfig();
            copyConfig(config, entity);
            aiConfigMapper.insert(entity);
            return entity;
        }

        copyConfig(config, existing);
        aiConfigMapper.updateById(existing);
        return existing;
    }

    @Override
    public RuntimeAiConfig getRuntimeConfig() {
        DsAiConfig config = getConfig();
        return new RuntimeAiConfig(
                config.getEnabled() != null && config.getEnabled() == 1,
                config.getProviderName(),
                config.getApiUrl(),
                config.getApiKey(),
                config.getModel(),
                config.getSystemPrompt()
        );
    }

    private DsAiConfig buildDefaultConfig() {
        DsAiConfig config = new DsAiConfig();
        config.setProviderName("OpenAI Compatible");
        config.setEnabled(defaultEnabled ? 1 : 0);
        config.setApiUrl(defaultApiUrl);
        config.setApiKey(defaultApiKey);
        config.setModel(defaultModel);
        config.setSystemPrompt(defaultSystemPrompt);
        return config;
    }

    private void copyConfig(DsAiConfig source, DsAiConfig target) {
        BeanUtils.copyProperties(source, target, "configId", "createBy", "createTime", "updateBy", "updateTime", "delFlag");
        if (!StringUtils.hasText(target.getProviderName())) {
            target.setProviderName("OpenAI Compatible");
        }
        if (target.getEnabled() == null) {
            target.setEnabled(0);
        }
    }
}
