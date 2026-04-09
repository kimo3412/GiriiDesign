import { RouteRecordRaw } from 'vue-router';
import { Layout } from '@/router/constant';
import { AppstoreOutlined } from '@vicons/antd';
import { renderIcon } from '@/utils/index';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/workbench',
    name: 'workbench',
    component: Layout,
    meta: {
      title: '节点工作台',
      icon: renderIcon(AppstoreOutlined),
      sort: 9,
    },
    children: [
      {
        path: 'nodes',
        name: 'workbench_nodes',
        component: () => import('@/views/order/workbench/index.vue'),
        meta: {
          title: '节点工作台',
        },
      },
    ],
  },
];

export default routes;
