import { defineStore } from 'pinia';
import { store } from '@/store';
import { ACCESS_TOKEN, CURRENT_USER, IS_SCREENLOCKED } from '@/store/mutation-types';
import { ResultEnum } from '@/enums/httpEnum';

import { getUserInfo as getUserInfoApi, login, logout as logoutApi } from '@/api/system/user';
import { storage } from '@/utils/Storage';

export type UserInfoType = {
  adminId: number;
  username: string;
  nickname: string;
  roles: string[];
  permissions: string[];
};

export interface IUserState {
  token: string;
  username: string;
  welcome: string;
  avatar: string;
  permissions: any[];
  info: UserInfoType;
}

export const useUserStore = defineStore({
  id: 'app-user',
  state: (): IUserState => ({
    token: storage.get(ACCESS_TOKEN, ''),
    username: '',
    welcome: '',
    avatar: '',
    permissions: [],
    info: storage.get(CURRENT_USER, {}),
  }),
  getters: {
    getToken(): string {
      return this.token;
    },
    getAvatar(): string {
      return this.avatar;
    },
    getNickname(): string {
      return this.info?.nickname || this.username || '';
    },
    getPermissions(): [any][] {
      return this.permissions;
    },
    getUserInfo(): UserInfoType {
      return this.info;
    },
  },
  actions: {
    setToken(token: string) {
      this.token = token;
    },
    setAvatar(avatar: string) {
      this.avatar = avatar;
    },
    setPermissions(permissions) {
      this.permissions = permissions;
    },
    setUserInfo(info: UserInfoType) {
      this.info = info;
    },

    // 登录 — 对接后端 /api/v1/auth/login
    async login(params: any) {
      const response = await login(params);
      const { data, code, msg } = response;
      if (code === ResultEnum.SUCCESS) {
        const ex = 7 * 24 * 60 * 60;
        storage.set(ACCESS_TOKEN, data.token, ex);
        storage.set(CURRENT_USER, data, ex);
        storage.set(IS_SCREENLOCKED, false);
        this.setToken(data.token);
        this.setUserInfo(data);
      }
      return response;
    },

    // 获取用户信息 — 对接后端 /api/v1/admin/info
    async getInfo() {
      const result = await getUserInfoApi();
      const { data, code } = result;
      if (code === ResultEnum.SUCCESS && data) {
        this.setPermissions(data.permissions || []);
        this.setUserInfo(data);
        this.username = data.username;
      }
      return data;
    },

    // 登出
    async logout() {
      try {
        await logoutApi();
      } catch (e) {
        // 即使后端接口失败，前端也清除登录态
      }
      this.setPermissions([]);
      this.setUserInfo({} as UserInfoType);
      this.setToken('');
      storage.remove(ACCESS_TOKEN);
      storage.remove(CURRENT_USER);
    },
  },
});

// Need to be used outside the setup
export function useUser() {
  return useUserStore(store);
}
