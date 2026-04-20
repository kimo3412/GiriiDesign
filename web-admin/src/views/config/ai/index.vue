<template>
  <div class="ai-config-page">
    <n-grid cols="1 s:1 m:3" responsive="screen" :x-gap="16" :y-gap="16">
      <n-grid-item>
        <BusinessMetricCard label="配置来源" :value="configSource" icon="AI" variant="primary" />
      </n-grid-item>
      <n-grid-item>
        <BusinessMetricCard label="当前状态" :value="enabledLabel" icon="ON" :variant="formData.enabled === 1 ? 'success' : 'warning'" />
      </n-grid-item>
      <n-grid-item>
        <BusinessMetricCard label="当前模型" :value="formData.model || '-'" icon="ML" variant="default" />
      </n-grid-item>
    </n-grid>

    <n-grid cols="1 s:1 m:2" responsive="screen" :x-gap="16" :y-gap="16" class="content-grid">
      <n-grid-item>
        <n-card :bordered="false" title="AI 配置">
          <template #header-extra>
            <n-tag :type="formData.enabled === 1 ? 'success' : 'default'" round>
              {{ enabledLabel }}
            </n-tag>
          </template>

          <n-form :model="formData" label-placement="top" class="config-form">
            <n-form-item label="启用 AI 客服">
              <n-switch v-model:value="formData.enabled" :checked-value="1" :unchecked-value="0">
                <template #checked>已启用</template>
                <template #unchecked>未启用</template>
              </n-switch>
            </n-form-item>

            <n-form-item label="服务商名称">
              <n-input v-model:value="formData.providerName" placeholder="例如：Volcengine / SiliconFlow / OpenAI Compatible" />
            </n-form-item>

            <n-form-item label="API 地址">
              <n-input v-model:value="formData.apiUrl" placeholder="请输入 OpenAI Compatible API 地址" />
            </n-form-item>

            <n-form-item label="API Key">
              <n-input
                v-model:value="formData.apiKey"
                type="password"
                show-password-on="click"
                placeholder="请输入 API Key"
              />
            </n-form-item>

            <n-form-item label="模型名称">
              <n-input v-model:value="formData.model" placeholder="例如：doubao-seed-1-6 / gpt-4.1-mini" />
            </n-form-item>

            <n-form-item label="系统提示词">
              <n-input
                v-model:value="formData.systemPrompt"
                type="textarea"
                :autosize="{ minRows: 6, maxRows: 12 }"
                placeholder="请输入 AI 客服系统提示词"
              />
            </n-form-item>

            <n-alert type="info" :show-icon="false" class="tips">
              当前实现使用 OpenAI Compatible 接口协议。数据库配置优先，若没有保存配置，则回退到后端
              <code>application.yml</code> 默认值。
            </n-alert>

            <n-space>
              <n-button type="primary" :loading="saving" @click="handleSave">保存配置</n-button>
              <n-button @click="loadConfig">重新加载</n-button>
            </n-space>
          </n-form>
        </n-card>
      </n-grid-item>

      <n-grid-item>
        <n-card :bordered="false" title="回复测试">
          <n-form label-placement="top">
            <n-form-item label="测试消息">
              <n-input
                v-model:value="testMessage"
                type="textarea"
                :autosize="{ minRows: 4, maxRows: 8 }"
                placeholder="输入一条客户消息，测试当前 AI 配置是否可用"
              />
            </n-form-item>
          </n-form>

          <n-space>
            <n-button type="primary" :loading="testing" @click="handleTest">发送测试</n-button>
            <n-button @click="clearTestResult">清空结果</n-button>
          </n-space>

          <div class="test-result">
            <div class="test-result__head">
              <span>测试结果</span>
              <n-tag v-if="testEnabled !== null" :type="testEnabled ? 'success' : 'warning'" round size="small">
                {{ testEnabled ? '配置可用' : '配置不可用' }}
              </n-tag>
            </div>
            <n-empty v-if="!testReply" description="尚未发送测试消息" />
            <div v-else class="reply-panel">{{ testReply }}</div>
          </div>
        </n-card>
      </n-grid-item>
    </n-grid>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue';
import { useMessage } from 'naive-ui';
import { BusinessMetricCard } from '@/components/Business';
import { getAiConfig, saveAiConfig, testAiConfig, type AiConfig } from '@/api/config/ai';

const message = useMessage();

const saving = ref(false);
const testing = ref(false);
const loadedFromDb = ref(false);
const testEnabled = ref<boolean | null>(null);
const testReply = ref('');
const testMessage = ref('你好，请介绍一下 ZeHana 工作室的定制流程。');

const formData = ref<AiConfig>({
  configId: null,
  providerName: 'OpenAI Compatible',
  enabled: 0,
  apiUrl: '',
  apiKey: '',
  model: '',
  systemPrompt: '',
});

const configSource = computed(() => (loadedFromDb.value ? '数据库' : 'YAML 默认值'));
const enabledLabel = computed(() => (formData.value.enabled === 1 ? '已启用' : '未启用'));

onMounted(() => {
  loadConfig();
});

async function loadConfig() {
  const res = await getAiConfig();
  formData.value = {
    configId: res?.configId ?? null,
    providerName: res?.providerName || 'OpenAI Compatible',
    enabled: res?.enabled ?? 0,
    apiUrl: res?.apiUrl || '',
    apiKey: res?.apiKey || '',
    model: res?.model || '',
    systemPrompt: res?.systemPrompt || '',
  };
  loadedFromDb.value = !!res?.configId;
}

async function handleSave() {
  saving.value = true;
  try {
    const res = await saveAiConfig(formData.value);
    formData.value = { ...formData.value, ...res };
    loadedFromDb.value = true;
    message.success('AI 配置已保存');
  } finally {
    saving.value = false;
  }
}

async function handleTest() {
  if (!testMessage.value.trim()) {
    message.warning('请先输入一条测试消息');
    return;
  }
  testing.value = true;
  try {
    const res = await testAiConfig(testMessage.value.trim());
    testEnabled.value = !!res?.enabled;
    testReply.value = res?.reply || '当前未返回测试结果';
  } finally {
    testing.value = false;
  }
}

function clearTestResult() {
  testEnabled.value = null;
  testReply.value = '';
}
</script>

<style scoped>
.ai-config-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.content-grid {
  margin-top: 4px;
}

.config-form {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.tips {
  margin-bottom: 12px;
}

.test-result {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid var(--border-light);
}

.test-result__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
  color: var(--text-secondary);
  font-size: 13px;
  font-weight: 600;
}

.reply-panel {
  min-height: 120px;
  padding: 14px 16px;
  border-radius: 12px;
  background: var(--page-bg);
  color: var(--text-primary);
  line-height: 1.8;
  white-space: pre-wrap;
}
</style>
