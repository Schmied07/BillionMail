import { RouteRecordRaw } from 'vue-router'
import { Layout } from '@/router/constant'

const route: RouteRecordRaw = {
        path: '/prospects',
        redirect: '/prospects/pipeline',
        name: 'ProspectsLayout',
        component: Layout,
        meta: {
                sort: 5,
                key: 'prospects',
                title: 'Prospects',
                titleKey: 'layout.menu.prospects',
        },
        children: [
                {
                        path: '/prospects',
                        name: 'Prospects',
                        redirect: '/prospects/pipeline',
                        component: () => import('@/views/prospects/index.vue'),
                        children: [
                                {
                                        path: 'pipeline',
                                        name: 'ProspectsPipeline',
                                        meta: { title: 'Pipeline', titleKey: 'prospects.menu.pipeline' },
                                        component: () => import('@/views/prospects/pipeline/index.vue'),
                                },
                                {
                                        path: 'list',
                                        name: 'ProspectsList',
                                        meta: { title: 'Liste', titleKey: 'prospects.menu.list' },
                                        component: () => import('@/views/prospects/list/index.vue'),
                                },
                                {
                                        path: 'reminders',
                                        name: 'ProspectsReminders',
                                        meta: { title: 'Rappels', titleKey: 'prospects.menu.reminders' },
                                        component: () => import('@/views/prospects/reminders/index.vue'),
                                },
                                {
                                        path: 'analytics',
                                        name: 'ProspectsAnalytics',
                                        meta: { title: 'Analytiques', titleKey: 'prospects.menu.analytics' },
                                        component: () => import('@/views/prospects/analytics/index.vue'),
                                },
                        ],
                },
        ],
}

export default route
