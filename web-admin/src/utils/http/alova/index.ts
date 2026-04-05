import { createAlova } from 'alova';
import VueHook from 'alova/vue';
import adapterFetch from 'alova/fetch';
import { isString } from 'lodash-es';
import { useUser } from '@/store/modules/user';
import { storage } from '@/utils/Storage';
import { useGlobSetting } from '@/hooks/setting';
import { PageEnum } from '@/enums/pageEnum';
import { ResultEnum } from '@/enums/httpEnum';
import { isUrl } from '@/utils';

const { apiUrl, urlPrefix } = useGlobSetting();

export const Alova = createAlova({
  baseURL: apiUrl,
  statesHook: VueHook,
  // 关闭 mock，使用真实后端 API
  requestAdapter: adapterFetch(),
  // 关闭 GET 请求缓存，确保每次都能拿到最新数据
  cacheFor: null,
  // 在开发环境开启缓存命中日志
  cacheLogger: process.env.NODE_ENV === 'development',
  beforeRequest(method) {
    const userStore = useUser();
    const token = userStore.getToken;
    // 添加 JWT Token 到请求头（Authorization: Bearer xxx）
    if (!method.meta?.ignoreToken && token) {
      method.config.headers['Authorization'] = `Bearer ${token}`;
    }
    // 处理 api 请求前缀
    const isUrlStr = isUrl(method.url as string);
    if (!isUrlStr && urlPrefix) {
      method.url = `${urlPrefix}${method.url}`;
    }
    if (!isUrlStr && apiUrl && isString(apiUrl)) {
      method.url = `${apiUrl}${method.url}`;
    }
  },
  responded: {
    onSuccess: async (response, method) => {
      const res = (response.json && (await response.json())) || response.body;

      // 是否返回原生响应头
      if (method.meta?.isReturnNativeResponse) {
        return res;
      }

      // 解构后端 R<T> 格式：{ code, msg, data }
      const { msg, code, data } = res;

      // 不进行任何处理，直接返回
      if (method.meta?.isTransformResponse === false) {
        return res;
      }

      // @ts-ignore
      const Message = window.$message;
      // @ts-ignore
      const Modal = window.$dialog;

      const LoginPath = PageEnum.BASE_LOGIN;

      if (ResultEnum.SUCCESS === code) {
        return data;
      }

      // Token 过期 → 清除登录态 → 跳转登录页
      if (code === ResultEnum.TOKEN_INVALID) {
        Modal?.warning({
          title: '提示',
          content: '登录已过期，请重新登录！',
          okText: '确定',
          closable: false,
          maskClosable: false,
          onOk: async () => {
            storage.clear();
            window.location.href = LoginPath;
          },
        });
      } else {
        // 其他错误，弹出提示
        Message?.error(msg || '请求失败');
        throw new Error(msg);
      }
    },
  },
});
