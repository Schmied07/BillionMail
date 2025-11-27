<template>
	<div class="analytics-container">
		<div class="analytics-header">
			<div class="header-left">
				<h2 class="page-title">
					<i class="i-mdi-chart-line mr-12px"></i>
					Analytiques Prospection
				</h2>
				<p class="page-subtitle">Suivez les performances de vos campagnes de prospection</p>
			</div>
			<div class="header-right">
				<n-select v-model:value="period" :options="periodOptions" style="width: 150px;" />
			</div>
		</div>

		<!-- KPI Cards -->
		<div class="kpi-grid">
			<div class="kpi-card" v-for="kpi in kpis" :key="kpi.label">
				<div class="kpi-header">
					<div class="kpi-icon" :style="{ background: kpi.gradient }">
						<i :class="kpi.icon"></i>
					</div>
					<div class="kpi-trend" :class="kpi.trend > 0 ? 'positive' : 'negative'">
						<i :class="kpi.trend > 0 ? 'i-mdi-trending-up' : 'i-mdi-trending-down'"></i>
						{{ Math.abs(kpi.trend) }}%
					</div>
				</div>
				<div class="kpi-value">{{ kpi.value }}</div>
				<div class="kpi-label">{{ kpi.label }}</div>
			</div>
		</div>

		<!-- Charts Row -->
		<div class="charts-row">
			<n-card class="chart-card" title="Evolution des Prospects">
				<div class="chart-placeholder">
					<div class="fake-chart line-chart">
						<div class="chart-line"></div>
						<div class="chart-dots">
							<span v-for="i in 7" :key="i" class="dot" :style="{ height: `${20 + Math.random() * 60}%` }"></span>
						</div>
					</div>
				</div>
			</n-card>
			<n-card class="chart-card" title="Répartition par Statut">
				<div class="status-distribution">
					<div class="status-item" v-for="status in statusDistribution" :key="status.label">
						<div class="status-bar">
							<div class="status-fill" :style="{ width: status.percentage + '%', background: status.color }"></div>
						</div>
						<div class="status-info">
							<span class="status-label">{{ status.label }}</span>
							<span class="status-value">{{ status.count }} ({{ status.percentage }}%)</span>
						</div>
					</div>
				</div>
			</n-card>
		</div>

		<!-- Performance Table -->
		<n-card title="Performance par Source">
			<n-data-table :columns="sourceColumns" :data="sourceData" :bordered="false" />
		</n-card>

		<!-- Conversion Funnel -->
		<n-card title="Entonnoir de Conversion" class="mt-24px">
			<div class="funnel-container">
				<div class="funnel-step" v-for="(step, index) in funnelSteps" :key="step.label">
					<div class="funnel-bar" :style="{ width: step.width + '%', background: step.color }">
						<span class="funnel-count">{{ step.count }}</span>
					</div>
					<div class="funnel-info">
						<span class="funnel-label">{{ step.label }}</span>
						<span class="funnel-rate" v-if="index > 0">{{ step.conversionRate }}%</span>
					</div>
				</div>
			</div>
		</n-card>
	</div>
</template>

<script lang="tsx" setup>
import { NTag, NProgress } from 'naive-ui'

const period = ref('month')

const periodOptions = [
	{ label: '7 jours', value: 'week' },
	{ label: '30 jours', value: 'month' },
	{ label: '90 jours', value: 'quarter' },
	{ label: '1 an', value: 'year' },
]

const kpis = [
	{
		label: 'Total Prospects',
		value: '156',
		trend: 12,
		icon: 'i-mdi-account-group',
		gradient: 'linear-gradient(135deg, #3b82f6, #60a5fa)',
	},
	{
		label: 'Nouveaux ce mois',
		value: '34',
		trend: 8,
		icon: 'i-mdi-account-plus',
		gradient: 'linear-gradient(135deg, #8b5cf6, #a78bfa)',
	},
	{
		label: 'Taux de Conversion',
		value: '23%',
		trend: 5,
		icon: 'i-mdi-target',
		gradient: 'linear-gradient(135deg, #10b981, #34d399)',
	},
	{
		label: 'Valeur Pipeline',
		value: '245k€',
		trend: -3,
		icon: 'i-mdi-cash-multiple',
		gradient: 'linear-gradient(135deg, #f59e0b, #fbbf24)',
	},
	{
		label: 'Temps Moyen Conversion',
		value: '18 jours',
		trend: -12,
		icon: 'i-mdi-clock-fast',
		gradient: 'linear-gradient(135deg, #06b6d4, #22d3ee)',
	},
	{
		label: 'Relances en Attente',
		value: '12',
		trend: 0,
		icon: 'i-mdi-bell-ring',
		gradient: 'linear-gradient(135deg, #ef4444, #f87171)',
	},
]

const statusDistribution = [
	{ label: 'Nouveaux', count: 45, percentage: 29, color: '#3b82f6' },
	{ label: 'Contactés', count: 38, percentage: 24, color: '#8b5cf6' },
	{ label: 'Qualifiés', count: 32, percentage: 21, color: '#f59e0b' },
	{ label: 'Négociation', count: 23, percentage: 15, color: '#06b6d4' },
	{ label: 'Convertis', count: 18, percentage: 11, color: '#10b981' },
]

const sourceColumns = [
	{ title: 'Source', key: 'source' },
	{ title: 'Prospects', key: 'prospects', align: 'center' as const },
	{ 
		title: 'Conversion', 
		key: 'conversion',
		align: 'center' as const,
		render: (row: any) => <NProgress type="line" percentage={row.conversion} indicator-placement="inside" processing />
	},
	{ 
		title: 'Valeur Moyenne', 
		key: 'avgValue',
		render: (row: any) => <span class="font-600 text-green-600">{row.avgValue}</span>
	},
	{ 
		title: 'Performance', 
		key: 'performance',
		render: (row: any) => {
			const type = row.performance === 'Excellent' ? 'success' : row.performance === 'Bon' ? 'info' : 'warning'
			return <NTag type={type} size="small">{row.performance}</NTag>
		}
	},
]

const sourceData = [
	{ source: 'LinkedIn', prospects: 52, conversion: 28, avgValue: '12 500€', performance: 'Excellent' },
	{ source: 'Site Web', prospects: 38, conversion: 22, avgValue: '8 200€', performance: 'Bon' },
	{ source: 'Salons', prospects: 24, conversion: 35, avgValue: '18 000€', performance: 'Excellent' },
	{ source: 'Recommandations', prospects: 28, conversion: 42, avgValue: '15 500€', performance: 'Excellent' },
	{ source: 'Cold Email', prospects: 14, conversion: 8, avgValue: '5 200€', performance: 'Moyen' },
]

const funnelSteps = [
	{ label: 'Prospects Identifiés', count: 156, width: 100, color: '#3b82f6' },
	{ label: 'Contactés', count: 112, width: 72, color: '#8b5cf6', conversionRate: 72 },
	{ label: 'Qualifiés', count: 68, width: 44, color: '#f59e0b', conversionRate: 61 },
	{ label: 'En Négociation', count: 42, width: 27, color: '#06b6d4', conversionRate: 62 },
	{ label: 'Convertis', count: 36, width: 23, color: '#10b981', conversionRate: 86 },
]
</script>

<style lang="scss" scoped>
.analytics-container {
	padding: 0;
}

.analytics-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	margin-bottom: 24px;
}

.page-title {
	display: flex;
	align-items: center;
	font-size: 24px;
	font-weight: 700;
	color: var(--color-text-1);
	margin: 0 0 4px 0;
}

.page-subtitle {
	font-size: 14px;
	color: var(--color-text-3);
	margin: 0;
}

.kpi-grid {
	display: grid;
	grid-template-columns: repeat(6, 1fr);
	gap: 16px;
	margin-bottom: 24px;
}

.kpi-card {
	background: var(--color-bg-1);
	border-radius: 16px;
	padding: 20px;
	box-shadow: var(--shadow-sm);
	border: 1px solid var(--color-border-1);
}

.kpi-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	margin-bottom: 16px;
}

.kpi-icon {
	width: 40px;
	height: 40px;
	border-radius: 10px;
	display: flex;
	align-items: center;
	justify-content: center;
	color: white;
	font-size: 20px;
}

.kpi-trend {
	display: flex;
	align-items: center;
	gap: 4px;
	font-size: 12px;
	font-weight: 600;

	&.positive {
		color: #10b981;
	}
	&.negative {
		color: #ef4444;
	}
}

.kpi-value {
	font-size: 28px;
	font-weight: 700;
	color: var(--color-text-1);
	margin-bottom: 4px;
}

.kpi-label {
	font-size: 13px;
	color: var(--color-text-3);
}

.charts-row {
	display: grid;
	grid-template-columns: 1.5fr 1fr;
	gap: 24px;
	margin-bottom: 24px;
}

.chart-placeholder {
	height: 250px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.fake-chart {
	width: 100%;
	height: 100%;
	position: relative;
}

.chart-dots {
	display: flex;
	align-items: flex-end;
	justify-content: space-around;
	height: 100%;
	padding: 20px;
}

.dot {
	width: 40px;
	background: linear-gradient(180deg, #3b82f6 0%, #60a5fa 100%);
	border-radius: 8px 8px 0 0;
	transition: height 0.3s ease;
}

.status-distribution {
	display: flex;
	flex-direction: column;
	gap: 16px;
	padding: 16px 0;
}

.status-item {
	display: flex;
	flex-direction: column;
	gap: 8px;
}

.status-bar {
	height: 24px;
	background: var(--color-bg-2);
	border-radius: 12px;
	overflow: hidden;
}

.status-fill {
	height: 100%;
	border-radius: 12px;
	transition: width 0.5s ease;
}

.status-info {
	display: flex;
	justify-content: space-between;
	font-size: 13px;
}

.status-label {
	color: var(--color-text-1);
	font-weight: 500;
}

.status-value {
	color: var(--color-text-3);
}

.funnel-container {
	display: flex;
	flex-direction: column;
	gap: 12px;
	padding: 20px;
}

.funnel-step {
	display: flex;
	align-items: center;
	gap: 16px;
}

.funnel-bar {
	height: 44px;
	border-radius: 8px;
	display: flex;
	align-items: center;
	padding: 0 16px;
	transition: width 0.5s ease;
}

.funnel-count {
	color: white;
	font-weight: 700;
	font-size: 16px;
}

.funnel-info {
	display: flex;
	flex-direction: column;
}

.funnel-label {
	font-size: 14px;
	font-weight: 500;
	color: var(--color-text-1);
}

.funnel-rate {
	font-size: 12px;
	color: var(--color-text-3);
}
</style>
