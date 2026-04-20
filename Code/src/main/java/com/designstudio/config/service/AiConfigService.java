package com.designstudio.config.service;

import com.designstudio.config.domain.DsAiConfig;

/**
 * AI config service.
 */
public interface AiConfigService {

    DsAiConfig getConfig();

    DsAiConfig saveConfig(DsAiConfig config);

    RuntimeAiConfig getRuntimeConfig();

    record RuntimeAiConfig(
            boolean enabled,
            String providerName,
            String apiUrl,
            String apiKey,
            String model,
            String systemPrompt
    ) {}
}
