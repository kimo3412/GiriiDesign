import { RouteRecordRaw } from 'vue-router';
import { Layout } from '@/router/constant';
import { ChatboxEllipsesOutline } from '@vicons/ionicons5';
import { renderIcon } from '@/utils/index';

const routeName = 'chat';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/chat',
    name: routeName,
    redirect: '/chat/index',
    component: Layout,
    meta: {
      title: '消息中心',
      icon: renderIcon(ChatboxEllipsesOutline),
      sort: 3,
    },
    children: [
      {
        path: 'index',
        name: `${routeName}_index`,
        meta: {
          title: '在线沟通',
        },
        component: () => import('@/views/chat/index.vue'),
      },
    ],
  },
];

export default routes;
