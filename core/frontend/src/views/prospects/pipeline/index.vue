<template>
        <div class="pipeline-container">
                <div class="pipeline-header">
                        <div class="header-left">
                                <h2 class="page-title">
                                        <i class="i-mdi-view-column-outline mr-12px"></i>
                                        Pipeline de Prospection
                                </h2>
                                <p class="page-subtitle">Gérez vos prospects par étape de conversion</p>
                        </div>
                        <div class="header-right">
                                <n-button @click="showImportModal = true">
                                        <template #icon>
                                                <i class="i-mdi-file-upload-outline"></i>
                                        </template>
                                        Importer CSV
                                </n-button>
                                <n-button type="primary" @click="showAddModal = true">
                                        <template #icon>
                                                <i class="i-mdi-plus"></i>
                                        </template>
                                        Nouveau Prospect
                                </n-button>
                        </div>
                </div>

                <!-- Pipeline Stats -->
                <div class="pipeline-stats">
                        <div class="stat-card" v-for="stat in pipelineStats" :key="stat.label">
                                <div class="stat-icon" :style="{ background: stat.gradient }">
                                        <i :class="stat.icon"></i>
                                </div>
                                <div class="stat-info">
                                        <span class="stat-value">{{ stat.value }}</span>
                                        <span class="stat-label">{{ stat.label }}</span>
                                </div>
                        </div>
                </div>

                <!-- Kanban Board -->
                <div class="kanban-board">
                        <div 
                                class="kanban-column" 
                                v-for="column in columns" 
                                :key="column.id"
                                :style="{ '--column-color': column.color }"
                        >
                                <div class="column-header">
                                        <div class="column-title">
                                                <span class="column-dot" :style="{ background: column.color }"></span>
                                                {{ column.title }}
                                        </div>
                                        <n-badge :value="getColumnProspects(column.id).length" :max="99" />
                                </div>
                                <div class="column-content">
                                        <div 
                                                class="prospect-card" 
                                                v-for="prospect in getColumnProspects(column.id)" 
                                                :key="prospect.id"
                                                @click="selectProspect(prospect)"
                                        >
                                                <div class="card-header">
                                                        <div class="prospect-avatar" :style="{ background: getAvatarColor(prospect.company) }">
                                                                {{ getInitials(prospect.company) }}
                                                        </div>
                                                        <div class="prospect-info">
                                                                <h4 class="prospect-name">{{ prospect.company }}</h4>
                                                                <span class="prospect-contact">{{ prospect.contact }}</span>
                                                        </div>
                                                        <n-dropdown :options="cardActions" @select="(key) => handleCardAction(key, prospect)">
                                                                <n-button text class="more-btn">
                                                                        <i class="i-mdi-dots-vertical"></i>
                                                                </n-button>
                                                        </n-dropdown>
                                                </div>
                                                <div class="card-body">
                                                        <div class="card-email">
                                                                <i class="i-mdi-email-outline"></i>
                                                                {{ prospect.email }}
                                                        </div>
                                                        <div class="card-meta">
                                                                <span class="meta-item" v-if="prospect.value">
                                                                        <i class="i-mdi-currency-eur"></i>
                                                                        {{ formatValue(prospect.value) }}
                                                                </span>
                                                                <span class="meta-item">
                                                                        <i class="i-mdi-star" :class="{ 'text-yellow-500': prospect.score >= 4 }"></i>
                                                                        {{ prospect.score }}/5
                                                                </span>
                                                        </div>
                                                </div>
                                                <div class="card-footer">
                                                        <div class="tags">
                                                                <n-tag v-for="tag in prospect.tags?.slice(0, 2)" :key="tag" size="small" :bordered="false">
                                                                        {{ tag }}
                                                                </n-tag>
                                                        </div>
                                                        <span class="last-contact" v-if="prospect.lastContact">
                                                                <i class="i-mdi-clock-outline"></i>
                                                                {{ formatDate(prospect.lastContact) }}
                                                        </span>
                                                </div>
                                        </div>
                                </div>
                        </div>
                </div>

                <!-- Add Prospect Modal -->
                <n-modal v-model:show="showAddModal" preset="card" title="Nouveau Prospect" style="width: 600px;">
                        <n-form ref="formRef" :model="formData" :rules="formRules" label-placement="top">
                                <n-grid :cols="2" :x-gap="16">
                                        <n-gi>
                                                <n-form-item label="Entreprise" path="company">
                                                        <n-input v-model:value="formData.company" placeholder="Nom de l'entreprise" />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi>
                                                <n-form-item label="Contact" path="contact">
                                                        <n-input v-model:value="formData.contact" placeholder="Nom du contact" />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi>
                                                <n-form-item label="Email" path="email">
                                                        <n-input v-model:value="formData.email" placeholder="email@exemple.com" />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi>
                                                <n-form-item label="Téléphone" path="phone">
                                                        <n-input v-model:value="formData.phone" placeholder="+33 1 23 45 67 89" />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi>
                                                <n-form-item label="Valeur estimée (€)" path="value">
                                                        <n-input-number v-model:value="formData.value" :min="0" placeholder="0" style="width: 100%;" />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi>
                                                <n-form-item label="Score (1-5)" path="score">
                                                        <n-rate v-model:value="formData.score" />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi :span="2">
                                                <n-form-item label="Source" path="source_id">
                                                        <n-select 
                                                                v-model:value="formData.source_id" 
                                                                :options="sourceOptions" 
                                                                :loading="loadingSources"
                                                                placeholder="Sélectionner une source" 
                                                        />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi :span="2">
                                                <n-form-item label="Statut" path="status">
                                                        <n-select v-model:value="formData.status" :options="statusOptions" placeholder="Sélectionner un statut" />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi :span="2">
                                                <n-form-item label="Tags" path="tags">
                                                        <n-select v-model:value="formData.tags" multiple :options="tagOptions" placeholder="Ajouter des tags" />
                                                </n-form-item>
                                        </n-gi>
                                        <n-gi :span="2">
                                                <n-form-item label="Notes" path="notes">
                                                        <n-input v-model:value="formData.notes" type="textarea" placeholder="Ajouter des notes..." :rows="3" />
                                                </n-form-item>
                                        </n-gi>
                                </n-grid>
                        </n-form>
                        <template #footer>
                                <div class="modal-footer">
                                        <n-button @click="showAddModal = false">Annuler</n-button>
                                        <n-button type="primary" @click="handleAddProspect">Ajouter</n-button>
                                </div>
                        </template>
                </n-modal>

                <!-- Prospect Detail Drawer -->
                <n-drawer v-model:show="showDrawer" :width="480" placement="right">
                        <n-drawer-content v-if="selectedProspect" :title="selectedProspect.company">
                                <template #header>
                                        <div class="drawer-header">
                                                <div class="prospect-avatar large" :style="{ background: getAvatarColor(selectedProspect.company) }">
                                                        {{ getInitials(selectedProspect.company) }}
                                                </div>
                                                <div>
                                                        <h3>{{ selectedProspect.company }}</h3>
                                                        <p>{{ selectedProspect.contact }}</p>
                                                </div>
                                        </div>
                                </template>
                                <div class="drawer-content">
                                        <div class="detail-section">
                                                <h4>Informations</h4>
                                                <div class="detail-item">
                                                        <i class="i-mdi-email-outline"></i>
                                                        <span>{{ selectedProspect.email }}</span>
                                                </div>
                                                <div class="detail-item" v-if="selectedProspect.phone">
                                                        <i class="i-mdi-phone-outline"></i>
                                                        <span>{{ selectedProspect.phone }}</span>
                                                </div>
                                                <div class="detail-item">
                                                        <i class="i-mdi-currency-eur"></i>
                                                        <span>{{ formatValue(selectedProspect.value) }}</span>
                                                </div>
                                                <div class="detail-item">
                                                        <i class="i-mdi-star"></i>
                                                        <n-rate :value="selectedProspect.score" readonly size="small" />
                                                </div>
                                        </div>
                                        <div class="detail-section">
                                                <h4>Statut</h4>
                                                <n-select v-model:value="selectedProspect.status" :options="statusOptions" @update:value="updateProspectStatus" />
                                        </div>
                                        <div class="detail-section">
                                                <h4>Tags</h4>
                                                <div class="tags-list">
                                                        <n-tag v-for="tag in selectedProspect.tags" :key="tag" :bordered="false" closable @close="removeTag(tag)">
                                                                {{ tag }}
                                                        </n-tag>
                                                </div>
                                        </div>
                                        <div class="detail-section">
                                                <h4>Notes</h4>
                                                <n-input v-model:value="selectedProspect.notes" type="textarea" placeholder="Ajouter des notes..." :rows="4" />
                                        </div>
                                        <div class="detail-section">
                                                <h4>Actions rapides</h4>
                                                <div class="quick-actions">
                                                        <n-button>
                                                                <template #icon><i class="i-mdi-email-send-outline"></i></template>
                                                                Envoyer email
                                                        </n-button>
                                                        <n-button>
                                                                <template #icon><i class="i-mdi-bell-plus-outline"></i></template>
                                                                Ajouter rappel
                                                        </n-button>
                                                </div>
                                        </div>
                                </div>
                        </n-drawer-content>
                </n-drawer>

                <!-- Import Modal -->
                <ImportModal v-model:show="showImportModal" @success="handleImportSuccess" />
        </div>
</template>

<script lang="ts" setup>
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'
import { useMessage, useDialog } from 'naive-ui'
import ImportModal from '../components/ImportModal.vue'
import { getProspectList, getSourceAll, createProspect, deleteProspects, updateProspect } from '@/api/modules/prospects'

const message = useMessage()
const dialog = useDialog()
const sources = ref<any[]>([])
const loadingSources = ref(false)

interface Prospect {
        id: string
        company: string
        contact: string
        email: string
        phone?: string
        value: number
        score: number
        status: string
        tags: string[]
        notes?: string
        lastContact?: number
        createdAt: number
        sourceId?: number
        sourceName?: string
}

const showAddModal = ref(false)
const showDrawer = ref(false)
const showImportModal = ref(false)
const selectedProspect = ref<Prospect | null>(null)

const columns = [
        { id: 'new', title: 'Nouveaux', color: '#3b82f6' },
        { id: 'contacted', title: 'Contactés', color: '#8b5cf6' },
        { id: 'qualified', title: 'Qualifiés', color: '#f59e0b' },
        { id: 'negotiation', title: 'Négociation', color: '#06b6d4' },
        { id: 'converted', title: 'Convertis', color: '#10b981' },
]

// Initialize with empty array - data will be loaded from API
const prospects = ref<Prospect[]>([])

const pipelineStats = computed(() => [
        {
                label: 'Total Prospects',
                value: prospects.value.length,
                icon: 'i-mdi-account-group',
                gradient: 'linear-gradient(135deg, #3b82f6, #60a5fa)',
        },
        {
                label: 'Valeur Pipeline',
                value: formatValue(prospects.value.reduce((sum, p) => sum + p.value, 0)),
                icon: 'i-mdi-cash-multiple',
                gradient: 'linear-gradient(135deg, #10b981, #34d399)',
        },
        {
                label: 'Taux Conversion',
                value: prospects.value.length > 0 ? Math.round((prospects.value.filter(p => p.status === 'converted').length / prospects.value.length) * 100) + '%' : '0%',
                icon: 'i-mdi-trending-up',
                gradient: 'linear-gradient(135deg, #f59e0b, #fbbf24)',
        },
        {
                label: 'Score Moyen',
                value: prospects.value.length > 0 ? (prospects.value.reduce((sum, p) => sum + p.score, 0) / prospects.value.length).toFixed(1) + '/5' : '0/5',
                icon: 'i-mdi-star',
                gradient: 'linear-gradient(135deg, #8b5cf6, #a78bfa)',
        },
])

const statusOptions = [
        { label: 'Nouveau', value: 'new' },
        { label: 'Contacté', value: 'contacted' },
        { label: 'Qualifié', value: 'qualified' },
        { label: 'Négociation', value: 'negotiation' },
        { label: 'Converti', value: 'converted' },
]

const tagOptions = [
        { label: 'Tech', value: 'Tech' },
        { label: 'Marketing', value: 'Marketing' },
        { label: 'Industrie', value: 'Industrie' },
        { label: 'Retail', value: 'Retail' },
        { label: 'Premium', value: 'Premium' },
        { label: 'Startup', value: 'Startup' },
        { label: 'Grand compte', value: 'Grand compte' },
]

const cardActions = [
        { label: 'Modifier', key: 'edit' },
        { label: 'Envoyer email', key: 'email' },
        { label: 'Ajouter rappel', key: 'reminder' },
        { type: 'divider', key: 'd1' },
        { label: 'Supprimer', key: 'delete' },
]

const formData = reactive({
        company: '',
        contact: '',
        email: '',
        phone: '',
        value: 0,
        score: 3,
        status: 'new',
        tags: [] as string[],
        notes: '',
        source_id: null as number | null,
})

const sourceOptions = computed(() =>
        sources.value.map((s) => ({
                label: s.name,
                value: s.id,
        }))
)

const formRules = {
        company: { required: true, message: 'Entreprise requise' },
        contact: { required: true, message: 'Contact requis' },
        email: { required: true, type: 'email', message: 'Email valide requis' },
        source_id: { required: true, type: 'number', message: 'Source requise' },
}

const getColumnProspects = (columnId: string) => {
        return prospects.value.filter(p => p.status === columnId)
}

const getInitials = (name: string) => {
        return name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase()
}

const getAvatarColor = (name: string) => {
        const colors = [
                'linear-gradient(135deg, #3b82f6, #60a5fa)',
                'linear-gradient(135deg, #8b5cf6, #a78bfa)',
                'linear-gradient(135deg, #10b981, #34d399)',
                'linear-gradient(135deg, #f59e0b, #fbbf24)',
                'linear-gradient(135deg, #ef4444, #f87171)',
        ]
        return colors[name.length % colors.length]
}

const formatValue = (value: number) => {
        if (value >= 1000) {
                return (value / 1000).toFixed(value >= 10000 ? 0 : 1) + 'k€'
        }
        return value + '€'
}

const formatDate = (timestamp: number) => {
        return format(new Date(timestamp), 'dd MMM', { locale: fr })
}

const selectProspect = (prospect: Prospect) => {
        selectedProspect.value = { ...prospect }
        showDrawer.value = true
}

const handleCardAction = (key: string, prospect: Prospect) => {
        switch (key) {
                case 'edit':
                        selectProspect(prospect)
                        break
                case 'delete':
                        dialog.warning({
                                title: 'Confirmer la suppression',
                                content: `Êtes-vous sûr de vouloir supprimer le prospect "${prospect.company}" ?`,
                                positiveText: 'Supprimer',
                                negativeText: 'Annuler',
                                onPositiveClick: async () => {
                                        try {
                                                await deleteProspects({ ids: [Number(prospect.id)] })
                                                message.success('Prospect supprimé avec succès')
                                                loadProspects()
                                        } catch (error) {
                                                console.error('Failed to delete prospect:', error)
                                                message.error('Erreur lors de la suppression du prospect')
                                        }
                                },
                        })
                        break
        }
}

const handleAddProspect = async () => {
        if (!formData.source_id) {
                message.warning('Veuillez sélectionner une source')
                return
        }
        
        try {
                const res = await createProspect({
                        company: formData.company || '',
                        contact: formData.contact || '',
                        email: formData.email || '',
                        phone: formData.phone || undefined,
                        value: formData.value || 0,
                        score: formData.score || 3,
                        status: formData.status || 'new',
                        tags: formData.tags || [],
                        notes: formData.notes || undefined,
                        source_id: formData.source_id,
                })
                
                message.success('Prospect ajouté avec succès')
                showAddModal.value = false
                // Reset form
                Object.assign(formData, { 
                        company: '', 
                        contact: '', 
                        email: '', 
                        phone: '', 
                        value: 0, 
                        score: 3, 
                        status: 'new', 
                        tags: [], 
                        notes: '',
                        source_id: null 
                })
                // Reload prospects
                loadProspects()
        } catch (error) {
                console.error('Failed to create prospect:', error)
                message.error('Erreur lors de la création du prospect')
        }
}

const updateProspectStatus = async (status: string) => {
        if (selectedProspect.value) {
                try {
                        await updateProspect({
                                id: Number(selectedProspect.value.id),
                                status: status,
                        })
                        const index = prospects.value.findIndex(p => p.id === selectedProspect.value?.id)
                        if (index !== -1) {
                                prospects.value[index].status = status
                        }
                        message.success('Statut mis à jour')
                } catch (error) {
                        console.error('Failed to update prospect status:', error)
                        message.error('Erreur lors de la mise à jour du statut')
                }
        }
}

const removeTag = async (tag: string) => {
        if (selectedProspect.value) {
                const newTags = selectedProspect.value.tags.filter(t => t !== tag)
                try {
                        await updateProspect({
                                id: Number(selectedProspect.value.id),
                                tags: newTags,
                        })
                        selectedProspect.value.tags = newTags
                        const index = prospects.value.findIndex(p => p.id === selectedProspect.value?.id)
                        if (index !== -1) {
                                prospects.value[index].tags = newTags
                        }
                } catch (error) {
                        console.error('Failed to remove tag:', error)
                        message.error('Erreur lors de la suppression du tag')
                }
        }
}

const loadProspects = async () => {
        try {
                const res = await getProspectList({ page: 1, page_size: 1000 })
                if (res.data?.data?.list) {
                        prospects.value = res.data.data.list.map((p: any) => ({
                                id: String(p.id),
                                company: p.company || '',
                                contact: p.contact || '',
                                email: p.email,
                                phone: p.phone || '',
                                value: p.value || 0,
                                score: p.score || 3,
                                status: p.status || 'new',
                                tags: p.tags || [],
                                notes: p.notes || '',
                                lastContact: p.last_contact ? p.last_contact * 1000 : undefined,
                                createdAt: p.create_time * 1000,
                                sourceId: p.source_id,
                                sourceName: p.source_name,
                        }))
                }
        } catch (error) {
                console.error('Failed to load prospects:', error)
        }
}

const handleImportSuccess = () => {
        message.success('Import réussi !')
        loadProspects()
}

const loadSources = async () => {
        loadingSources.value = true
        try {
                const res = await getSourceAll()
                if (res.data?.data?.list) {
                        sources.value = res.data.data.list
                }
        } catch (error) {
                console.error('Failed to load sources:', error)
        } finally {
                loadingSources.value = false
        }
}

// Load prospects and sources on mount
onMounted(() => {
        loadProspects()
        loadSources()
})
</script>

<style lang="scss" scoped>
.pipeline-container {
        padding: 0;
}

.pipeline-header {
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

.pipeline-stats {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
}

.stat-card {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 20px;
        background: var(--color-bg-1);
        border-radius: 16px;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--color-border-1);
}

.stat-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 48px;
        height: 48px;
        border-radius: 12px;
        color: white;
        font-size: 24px;
}

.stat-info {
        display: flex;
        flex-direction: column;
}

.stat-value {
        font-size: 24px;
        font-weight: 700;
        color: var(--color-text-1);
}

.stat-label {
        font-size: 13px;
        color: var(--color-text-3);
}

.kanban-board {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 16px;
        min-height: calc(100vh - 350px);
}

.kanban-column {
        background: var(--color-bg-2);
        border-radius: 16px;
        padding: 16px;
        display: flex;
        flex-direction: column;
}

.column-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        padding-bottom: 12px;
        border-bottom: 2px solid var(--column-color, var(--color-border-1));
}

.column-title {
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 600;
        color: var(--color-text-1);
}

.column-dot {
        width: 10px;
        height: 10px;
        border-radius: 50%;
}

.column-content {
        flex: 1;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        gap: 12px;
}

.prospect-card {
        background: var(--color-bg-1);
        border-radius: 12px;
        padding: 16px;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--color-border-1);
        cursor: pointer;
        transition: all 0.2s ease;

        &:hover {
                box-shadow: var(--shadow-md);
                transform: translateY(-2px);
                border-color: var(--color-primary-1);
        }
}

.card-header {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        margin-bottom: 12px;
}

.prospect-avatar {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 600;
        font-size: 14px;
        flex-shrink: 0;

        &.large {
                width: 56px;
                height: 56px;
                font-size: 18px;
                border-radius: 14px;
        }
}

.prospect-info {
        flex: 1;
        min-width: 0;
}

.prospect-name {
        font-size: 14px;
        font-weight: 600;
        color: var(--color-text-1);
        margin: 0 0 2px 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
}

.prospect-contact {
        font-size: 12px;
        color: var(--color-text-3);
}

.more-btn {
        opacity: 0;
        transition: opacity 0.2s;

        .prospect-card:hover & {
                opacity: 1;
        }
}

.card-body {
        margin-bottom: 12px;
}

.card-email {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 12px;
        color: var(--color-text-2);
        margin-bottom: 8px;

        i {
                color: var(--color-text-3);
        }
}

.card-meta {
        display: flex;
        gap: 12px;
}

.meta-item {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 12px;
        color: var(--color-text-2);

        i {
                color: var(--color-text-3);
        }
}

.card-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-top: 12px;
        border-top: 1px solid var(--color-border-1);
}

.tags {
        display: flex;
        gap: 4px;
}

.last-contact {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 11px;
        color: var(--color-text-3);
}

.modal-footer {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
}

.drawer-header {
        display: flex;
        align-items: center;
        gap: 16px;

        h3 {
                margin: 0;
                font-size: 18px;
                color: var(--color-text-1);
        }

        p {
                margin: 4px 0 0;
                font-size: 14px;
                color: var(--color-text-3);
        }
}

.drawer-content {
        padding: 0;
}

.detail-section {
        margin-bottom: 24px;

        h4 {
                font-size: 13px;
                font-weight: 600;
                color: var(--color-text-3);
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin: 0 0 12px 0;
        }
}

.detail-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 10px 0;
        border-bottom: 1px solid var(--color-border-1);

        i {
                color: var(--color-text-3);
                font-size: 18px;
        }

        span {
                color: var(--color-text-1);
        }
}

.tags-list {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
}

.quick-actions {
        display: flex;
        gap: 12px;
}
</style>
