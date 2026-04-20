package com.designstudio.common.service.impl;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.designstudio.common.service.AiCustomerService;
import com.designstudio.config.service.AiConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * AI customer service implementation for OpenAI-compatible APIs.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiCustomerServiceImpl implements AiCustomerService {

    private final AiConfigService aiConfigService;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    @Override
    public boolean isEnabled() {
        AiConfigService.RuntimeAiConfig config = aiConfigService.getRuntimeConfig();
        return config.enabled()
                && StringUtils.hasText(config.apiUrl())
                && StringUtils.hasText(config.apiKey())
                && StringUtils.hasText(config.model());
    }

    @Override
    public String getResponse(Long userId, List<Message> messages) {
        AiConfigService.RuntimeAiConfig config = aiConfigService.getRuntimeConfig();
        if (!isUsable(config)) {
            return null;
        }

        try {
            String requestBody = buildRequestBody(messages, config);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(config.apiUrl()))
                    .timeout(Duration.ofSeconds(30))
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + config.apiKey())
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                log.error("AI customer service request failed, status={}, body={}", response.statusCode(), response.body());
                return fallbackReply();
            }

            String reply = parseResponse(response.body());
            return (reply == null || reply.isBlank()) ? fallbackReply() : reply.trim();
        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
            log.error("AI customer service request failed", e);
            return fallbackReply();
        } catch (Exception e) {
            log.error("AI customer service request failed", e);
            return fallbackReply();
        }
    }

    private boolean isUsable(AiConfigService.RuntimeAiConfig config) {
        return config.enabled()
                && StringUtils.hasText(config.apiUrl())
                && StringUtils.hasText(config.apiKey())
                && StringUtils.hasText(config.model());
    }

    private String buildRequestBody(List<Message> messages, AiConfigService.RuntimeAiConfig config) {
        List<Map<String, String>> chatMessages = new ArrayList<>();
        if (StringUtils.hasText(config.systemPrompt())) {
            chatMessages.add(Map.of("role", "system", "content", config.systemPrompt()));
        }
        for (Message msg : messages) {
            chatMessages.add(Map.of(
                    "role", msg.role(),
                    "content", msg.content() == null ? "" : msg.content()
            ));
        }

        Map<String, Object> requestBody = Map.of(
                "model", config.model(),
                "messages", chatMessages,
                "max_tokens", 500,
                "temperature", 0.7
        );
        return JSONUtil.toJsonStr(requestBody);
    }

    private String parseResponse(String response) {
        if (response == null || response.isBlank()) {
            return null;
        }
        try {
            JSONObject json = JSONUtil.parseObj(response);
            var choices = json.getJSONArray("choices");
            if (choices != null && !choices.isEmpty()) {
                var message = choices.getJSONObject(0).getJSONObject("message");
                if (message != null) {
                    return message.getStr("content");
                }
            }
        } catch (Exception e) {
            log.error("Failed to parse AI response: {}", response, e);
        }
        return null;
    }

    private String fallbackReply() {
        return "抱歉，小Z暂时无法回答这个问题，请联系人工客服。";
    }
}
