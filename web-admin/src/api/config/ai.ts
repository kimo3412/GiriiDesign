import { Alova } from '@/utils/http/alova/index';

export interface AiConfig {
  configId?: number | null;
  providerName?: string;
  enabled?: number;
  apiUrl?: string;
  apiKey?: string;
  model?: string;
  systemPrompt?: string;
}

export interface AiTestResponse {
  enabled: boolean;
  reply: string;
}

export function getAiConfig() {
  return Alova.Get<AiConfig>('/v1/admin/ai-config');
}

export function saveAiConfig(data: AiConfig) {
  return Alova.Put<AiConfig>('/v1/admin/ai-config', data);
}

export function testAiConfig(message: string) {
  return Alova.Post<AiTestResponse>('/v1/admin/ai-config/test', { message });
}
