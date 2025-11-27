<template>
        <n-card class="metric-card" :bordered="false">
                <div class="card-content">
                        <div class="card-icon" :style="{ background: iconGradient }">
                                <i :class="iconClass"></i>
                        </div>
                        <div class="card-info">
                                <div class="title">{{ title }}</div>
                                <div class="value" :style="{ color: textColor }">{{ value }}{{ unit }}</div>
                        </div>
                </div>
        </n-card>
</template>

<script setup lang="ts">
const props = defineProps({
        title: {
                type: String,
                default: '',
        },
        value: {
                type: Number,
                default: 0,
        },
        unit: {
                type: String,
                default: '',
        },
        textColor: {
                type: String,
        },
})

const iconMap: Record<string, { icon: string; gradient: string }> = {
        'Delivered': { icon: 'i-mdi-check-circle-outline', gradient: 'linear-gradient(135deg, #10b981, #34d399)' },
        'Opened': { icon: 'i-mdi-email-open-outline', gradient: 'linear-gradient(135deg, #3b82f6, #60a5fa)' },
        'Clicked': { icon: 'i-mdi-cursor-default-click-outline', gradient: 'linear-gradient(135deg, #8b5cf6, #a78bfa)' },
        'Bounced': { icon: 'i-mdi-email-remove-outline', gradient: 'linear-gradient(135deg, #ef4444, #f87171)' },
        'Delayed Queue': { icon: 'i-mdi-clock-alert-outline', gradient: 'linear-gradient(135deg, #f59e0b, #fbbf24)' },
}

const iconClass = computed(() => {
        return iconMap[props.title]?.icon || 'i-mdi-chart-line'
})

const iconGradient = computed(() => {
        return iconMap[props.title]?.gradient || 'linear-gradient(135deg, #6366f1, #818cf8)'
})
</script>

<style lang="scss" scoped>
.metric-card {
        --n-padding-top: 20px;
        --n-padding-bottom: 20px;
        --n-padding-left: 20px;
        --n-padding-right: 20px;
        --n-text-color: var(--color-card-text-1);
        border-radius: 16px;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--color-border-1);
        transition: all 0.3s ease;
        
        &:hover {
                box-shadow: var(--shadow-md);
                transform: translateY(-2px);
        }
}

.card-content {
        display: flex;
        align-items: center;
        gap: 16px;
}

.card-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 48px;
        height: 48px;
        border-radius: 12px;
        color: white;
        font-size: 24px;
        flex-shrink: 0;
}

.card-info {
        flex: 1;
        min-width: 0;
}

.title {
        font-size: 13px;
        font-weight: 500;
        color: var(--color-text-3);
        margin-bottom: 4px;
}

.value {
        font-size: 24px;
        font-weight: 700;
        color: var(--color-text-1);
}
</style>