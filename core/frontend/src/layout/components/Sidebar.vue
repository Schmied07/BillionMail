<template>
	<n-layout-sider
		collapse-mode="width"
		:collapsed="isCollapse"
		:width="220"
		:collapsed-width="68"
		:content-style="{
			display: 'flex',
			flexDirection: 'column',
			height: '100%',
			overflow: 'hidden',
		}">
		<!-- Logo et nom de l'application -->
		<div class="app-logo" :class="{ collapse: isCollapse }">
			<router-link to="/overview" class="logo-link">
				<TetrisLogo :size="isCollapse ? 32 : 38" />
				<transition name="fade">
					<span v-show="!isCollapse" class="app-name">TETRISNEWS</span>
				</transition>
			</router-link>
		</div>

		<!-- Menu de navigation -->
		<div class="nav-section">
			<n-menu
				:value="activeMenuKey"
				:collapsed="isCollapse"
				:collapsed-width="68"
				:options="menuOptions"
				:root-indent="20"
				@update:value="handleUpdateMenu">
			</n-menu>
		</div>
		<!-- Bouton de déconnexion -->
		<div class="footer-section">
			<n-menu
				value=""
				:collapsed="isCollapse"
				:collapsed-width="68"
				:options="logoutOptions"
				:root-indent="20"
				@update:value="handleUpdateMenu">
			</n-menu>
		</div>
	</n-layout-sider>
</template>

<script lang="tsx" setup>
import { VNodeChild } from 'vue'
import { MenuOption } from 'naive-ui'
import { storeToRefs } from 'pinia'
import { RouterLink } from 'vue-router'
import { useMenuStore, useGlobalStore, useUserStore } from '@/store'
import { menuList } from '@/router/router'
import TetrisLogo from '@/components/common/TetrisLogo.vue'

const { t } = useI18n()

const route = useRoute()

const menuStore = useMenuStore()
const userStore = useUserStore()
const globalStore = useGlobalStore()

const { isCollapse } = storeToRefs(globalStore)

// Clé du menu actif
const activeMenuKey = computed(() => {
	return String(route.meta?.key || '')
})

// Menus du routeur
const routerMenus = computed(() => {
	return menuStore.menuList.filter(route => route.meta && !route.meta.hidden)
})

// Options du menu de navigation
const menuOptions = computed(() => {
	return routerMenus.value.map(route => {
		const name = String(route.children?.[0]?.name || '')
		const key = String(route.meta?.key || '')
		const titleKey = String(route.meta?.titleKey || '')
		const title = titleKey ? t(titleKey) : String(route.meta?.title || '')
		return {
			key,
			label: () => renderLabel(name, title),
			icon: () => renderIcon(key),
		}
	})
})

const logoutOptions = ref<MenuOption[]>([
	{
		key: 'logout',
		label: () => <span class="ml-10px">{t('layout.menu.logout')}</span>,
		icon: () => renderIcon('logout'),
	},
])

const renderLabel = (name: string, title: string) => {
	return (
		<RouterLink class="flex items-center" to={{ name }}>
			<span>{title}</span>
		</RouterLink>
	)
}

const iconMap: Record<string, VNodeChild> = {
	overview: <i class="i-mdi-view-dashboard-outline"></i>,
	market: <i class="i-mdi-email-fast-outline"></i>,
	api: <i class="i-mdi-api"></i>,
	contacts: <i class="i-mdi-account-group-outline"></i>,
	domain: <i class="i-mdi-web"></i>,
	mailbox: <i class="i-custom:mailbox"></i>,
	smtp: <i class="i-custom:smtp"></i>,
	settings: <i class="i-mdi-cog-outline"></i>,
	template: <i class="i-mdi-file-document-outline"></i>,
	logs: <i class="i-icon-park-outline:log"></i>,
	logout: <i class="i-mdi-logout"></i>,
}

const renderIcon = (key: string) => {
	return iconMap[key]
}

const handleUpdateMenu = (key: string) => {
	if (key === 'logout') {
		userStore.logout()
	}
	if (key === 'webmail') {
		const route = routerMenus.value.find(item => item.meta?.key === 'webmail')
		if (route) {
			const href = String(route.meta?.href)
			window.open(href)
		}
	}
}

onMounted(() => {
	menuStore.setMenuList(menuList)
})
</script>

<style lang="scss" scoped>
.n-layout-sider {
	background: linear-gradient(180deg, #1e3a8a 0%, #1e40af 50%, #2563eb 100%);
	box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);
	z-index: 1010;
}

.app-logo {
	display: flex;
	padding: 20px 16px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.1);
	transition: all 0.3s ease;

	&.collapse {
		justify-content: center;
		padding: 20px 0;
	}

	.logo-link {
		display: flex;
		align-items: center;
		gap: 12px;
		text-decoration: none;
	}

	.app-name {
		font-size: 17px;
		font-weight: 700;
		color: #ffffff;
		letter-spacing: 0.5px;
		white-space: nowrap;
	}
}

.nav-section {
	flex: 1;
	overflow-y: auto;
	overflow-x: hidden;
	padding: 8px 0;
	
	&::-webkit-scrollbar {
		width: 4px;
	}
	
	&::-webkit-scrollbar-thumb {
		background: rgba(255, 255, 255, 0.2);
		border-radius: 4px;
	}
}

.footer-section {
	border-top: 1px solid rgba(255, 255, 255, 0.1);
	padding: 8px 0;
}

.n-menu {
	--n-item-height: 44px;
	--n-font-size: 14px;
	--n-item-text-color: rgba(255, 255, 255, 0.85);
	--n-item-text-color-hover: #ffffff;
	--n-item-text-color-active: #ffffff;
	--n-item-icon-color: rgba(255, 255, 255, 0.7);
	--n-item-icon-color-hover: #ffffff;
	--n-item-icon-color-active: #ffffff;
	--n-item-color-hover: rgba(255, 255, 255, 0.1);
	--n-item-color-active: rgba(255, 255, 255, 0.15);
	--n-item-color-active-hover: rgba(255, 255, 255, 0.2);
	background: transparent;

	:deep(.n-menu-item) {
		margin: 4px 8px;
		border-radius: 8px;
		transition: all 0.2s ease;

		&:hover {
			background: rgba(255, 255, 255, 0.1);
		}

		.n-menu-item-content {
			padding: 0 12px;
			border-radius: 8px;
			
			&.n-menu-item-content--selected {
				background: rgba(255, 255, 255, 0.2);
				
				&::before {
					content: '';
					position: absolute;
					left: 0;
					top: 50%;
					transform: translateY(-50%);
					width: 3px;
					height: 60%;
					background: #ffffff;
					border-radius: 0 3px 3px 0;
				}
			}
		}
		
		.n-menu-item-content__icon {
			font-size: 20px;
		}
	}
}

.fade-enter-active,
.fade-leave-active {
	transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
	opacity: 0;
}
</style>