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
                                <n-button @click="loadStats" :loading="loading">
                                        <template #icon><i class="i-mdi-refresh"></i></template>
                                        Actualiser
                                </n-button>
                        </div>
                </div>

                <!-- Loading State -->
                <n-spin :show="loading">
                        <!-- KPI Cards -->
                        <div class="kpi-grid">
                                <div v-for="kpi in kpis" :key="kpi.label" class="kpi-card">
                                        <div class="kpi-header">
                                                <div class="kpi-icon" :style="{ background: kpi.gradient }">
                                                        <i :class="kpi.icon"></i>
                                                </div>
                                        </div>
                                        <div class="kpi-value">{{ kpi.value }}</div>
                                        <div class="kpi-label">{{ kpi.label }}</div>
                                </div>
                        </div>

                        <!-- Charts Row -->
                        <div class="charts-row">
                                <n-card class="chart-card" title="Répartition par Statut">
                                        <div v-if="statusDistribution.length > 0" class="status-distribution">
                                                <div v-for="status in statusDistribution" :key="status.label" class="status-item">
                                                        <div class="status-bar">
                                                                <div class="status-fill" :style="{ width: status.percentage + '%', background: status.color }"></div>
                                                        </div>
                                                        <div class="status-info">
                                                                <span class="status-label">{{ status.label }}</span>
                                                                <span class="status-value">{{ status.count }} ({{ status.percentage.toFixed(1) }}%)</span>
                                                        </div>
                                                </div>
                                        </div>
                                        <n-empty v-else description="Aucune donnée de statut" />
                                </n-card>
                                <n-card class="chart-card" title="Répartition par Source">
                                        <div v-if="sourceDistribution.length > 0" class="status-distribution">
                                                <div v-for="source in sourceDistribution" :key="source.label" class="status-item">
                                                        <div class="status-bar">
                                                                <div class="status-fill" :style="{ width: source.percentage + '%', background: source.color }"></div>
                                                        </div>
                                                        <div class="status-info">
                                                                <span class="status-label">{{ source.label }}</span>
                                                                <span class="status-value">{{ source.count }} ({{ source.percentage.toFixed(1) }}%)</span>
                                                        </div>
                                                </div>
                                        </div>
                                        <n-empty v-else description="Aucune donnée de source" />
                                </n-card>
                        </div>

                        <!-- Conversion Funnel -->
                        <n-card v-if="funnelSteps.length > 0" title="Entonnoir de Conversion" class="mt-24px">
                                <div class="funnel-container">
                                        <div v-for="(step, index) in funnelSteps" :key="step.label" class="funnel-step">
                                                <div class="funnel-bar" :style="{ width: step.width + '%', background: step.color }">
                                                        <span class="funnel-count">{{ step.count }}</span>
                                                </div>
                                                <div class="funnel-info">
                                                        <span class="funnel-label">{{ step.label }}</span>
                                                        <span v-if="index > 0 && step.conversionRate" class="funnel-rate">{{ step.conversionRate.toFixed(1) }}%</span>
                                                </div>
                                        </div>
                                </div>
                        </n-card>
                </n-spin>
        </div>
</template>

<script lang="tsx" setup>
import { ref, computed, onMounted } from 'vue'
import { getProspectStats, getReminderList } from '@/api/modules/prospects'

const loading = ref(false)

// Stats data from API
const stats = ref({
        total_count: 0,
        total_value: 0,
        average_score: 0,
        conversion_rate: 0,
        status_breakdown: {} as Record<string, number>,
        source_breakdown: {} as Record<string, number>,
})

const pendingReminders = ref(0)

// Status labels and colors mapping
const statusConfig: Record<string, { label: string; color: string; order: number }> = {
        'new': { label: 'Nouveaux', color: '#3b82f6', order: 1 },
        'contacted': { label: 'Contactés', color: '#8b5cf6', order: 2 },
        'qualified': { label: 'Qualifiés', color: '#f59e0b', order: 3 },
        'negotiation': { label: 'Négociation', color: '#06b6d4', order: 4 },
        'converted': { label: 'Convertis', color: '#10b981', order: 5 },
        'lost': { label: 'Perdus', color: '#ef4444', order: 6 },
}

// Source colors (generate dynamically)
const sourceColors = ['#3b82f6', '#8b5cf6', '#f59e0b', '#06b6d4', '#10b981', '#ef4444', '#ec4899', '#14b8a6']

// Computed KPIs
const kpis = computed(() => [
        {
                label: 'Total Prospects',
                value: stats.value.total_count.toString(),
                icon: 'i-mdi-account-group',
                gradient: 'linear-gradient(135deg, #3b82f6, #60a5fa)',
        },
        {
                label: 'Taux de Conversion',
                value: stats.value.conversion_rate.toFixed(1) + '%',
                icon: 'i-mdi-target',
                gradient: 'linear-gradient(135deg, #10b981, #34d399)',
        },
        {
                label: 'Valeur Pipeline',
                value: formatValue(stats.value.total_value),
                icon: 'i-mdi-cash-multiple',
                gradient: 'linear-gradient(135deg, #f59e0b, #fbbf24)',
        },
        {
                label: 'Score Moyen',
                value: stats.value.average_score.toFixed(0) + '/100',
                icon: 'i-mdi-star',
                gradient: 'linear-gradient(135deg, #8b5cf6, #a78bfa)',
        },
        {
                label: 'Relances en Attente',
                value: pendingReminders.value.toString(),
                icon: 'i-mdi-bell-ring',
                gradient: 'linear-gradient(135deg, #ef4444, #f87171)',
        },
])

// Computed status distribution
const statusDistribution = computed(() => {
        const breakdown = stats.value.status_breakdown
        const total = Object.values(breakdown).reduce((sum, count) => sum + count, 0)
        if (total === 0) return []
        
        return Object.entries(breakdown)
                .map(([status, count]) => {
                        const config = statusConfig[status] || { label: status, color: '#6b7280', order: 99 }
                        return {
                                label: config.label,
                                count,
                                percentage: (count / total) * 100,
                                color: config.color,
                                order: config.order,
                        }
                })
                .sort((a, b) => a.order - b.order)
})

// Computed source distribution
const sourceDistribution = computed(() => {
        const breakdown = stats.value.source_breakdown
        const total = Object.values(breakdown).reduce((sum, count) => sum + count, 0)
        if (total === 0) return []
        
        return Object.entries(breakdown)
                .map(([source, count], index) => ({
                        label: source || 'Sans source',
                        count,
                        percentage: (count / total) * 100,
                        color: sourceColors[index % sourceColors.length],
                }))
                .sort((a, b) => b.count - a.count)
})

// Computed funnel steps
const funnelSteps = computed(() => {
        const breakdown = stats.value.status_breakdown
        const total = stats.value.total_count
        if (total === 0) return []
        
        const steps = [
                { key: 'new', label: 'Prospects Identifiés', color: '#3b82f6' },
                { key: 'contacted', label: 'Contactés', color: '#8b5cf6' },
                { key: 'qualified', label: 'Qualifiés', color: '#f59e0b' },
                { key: 'negotiation', label: 'En Négociation', color: '#06b6d4' },
                { key: 'converted', label: 'Convertis', color: '#10b981' },
        ]
        
        let previousCount = total
        return steps.map((step, index) => {
                const count = breakdown[step.key] || 0
                const width = total > 0 ? (count / total) * 100 : 0
                const conversionRate = index > 0 && previousCount > 0 ? (count / previousCount) * 100 : undefined
                previousCount = count > 0 ? count : previousCount
                
                return {
                        ...step,
                        count,
                        width: Math.max(width, 5), // Minimum width for visibility
                        conversionRate,
                }
        })
})

// Format value as currency
function formatValue(value: number): string {
        if (value >= 1000000) {
                return (value / 1000000).toFixed(1) + 'M€'
        } else if (value >= 1000) {
                return (value / 1000).toFixed(0) + 'k€'
        }
        return value + '€'
}

// Load stats from API
async function loadStats() {
        loading.value = true
        try {
                // Load prospect stats
                const response = await getProspectStats()
                if (response.data?.success && response.data?.data) {
                        stats.value = response.data.data
                }
                
                // Load pending reminders count
                const remindersResponse = await getReminderList({ completed: false, page: 1, page_size: 1 })
                if (remindersResponse.data?.success && remindersResponse.data?.data) {
                        pendingReminders.value = remindersResponse.data.data.total || 0
                }
        } catch (error) {
                console.error('Failed to load stats:', error)
        } finally {
                loading.value = false
        }
}

onMounted(() => {
        loadStats()
})
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

.header-right {
        display: flex;
        gap: 12px;
}

.kpi-grid {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
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
        grid-template-columns: 1fr 1fr;
        gap: 24px;
        margin-bottom: 24px;
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
