<template>
	<div class="list-container">
		<div class="list-header">
			<div class="header-left">
				<h2 class="page-title">
					<i class="i-mdi-format-list-bulleted mr-12px"></i>
					Liste des Prospects
				</h2>
				<p class="page-subtitle">Vue détaillée de tous vos prospects</p>
			</div>
			<div class="header-right">
				<n-input-group>
					<n-input v-model:value="searchQuery" placeholder="Rechercher..." style="width: 250px;">
						<template #prefix>
							<i class="i-mdi-magnify"></i>
						</template>
					</n-input>
					<n-select v-model:value="filterStatus" :options="statusOptions" placeholder="Statut" style="width: 150px;" clearable />
					<n-select v-model:value="filterSource" :options="sourceOptions" placeholder="Source" style="width: 150px;" clearable />
				</n-input-group>
				<n-button @click="showImportModal = true">
					<template #icon>
						<i class="i-mdi-file-upload-outline"></i>
					</template>
					Importer CSV
				</n-button>
				<n-button type="primary" @click="handleExport" :loading="exporting">
					<template #icon>
						<i class="i-mdi-download"></i>
					</template>
					Exporter
				</n-button>
			</div>
		</div>

		<n-data-table
			:columns="columns"
			:data="filteredProspects"
			:pagination="pagination"
			:bordered="false"
			:row-key="(row) => row.id"
			:loading="loading"
		>
		</n-data-table>

		<!-- Import Modal -->
		<ImportModal v-model:show="showImportModal" @success="handleImportSuccess" />
	</div>
</template>

<script lang="tsx" setup>
import { NButton, NTag, NRate, NFlex, useMessage, useDialog } from 'naive-ui'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'
import ImportModal from '../components/ImportModal.vue'
import { getProspectList, getSourceAll, deleteProspects } from '@/api/modules/prospects'

const message = useMessage()
const dialog = useDialog()
const loading = ref(false)
const exporting = ref(false)
const showImportModal = ref(false)

const searchQuery = ref('')
const filterStatus = ref<string | null>(null)
const filterSource = ref<number | null>(null)
const sources = ref<any[]>([])

const prospects = ref<any[]>([])

const statusOptions = [
	{ label: 'Nouveau', value: 'new' },
	{ label: 'Contacté', value: 'contacted' },
	{ label: 'Qualifié', value: 'qualified' },
	{ label: 'Négociation', value: 'negotiation' },
	{ label: 'Converti', value: 'converted' },
]

const sourceOptions = computed(() =>
	sources.value.map((s) => ({
		label: s.name,
		value: s.id,
	}))
)

const statusConfig: Record<string, { label: string; type: 'info' | 'warning' | 'success' | 'error' | 'default' }> = {
	new: { label: 'Nouveau', type: 'info' },
	contacted: { label: 'Contacté', type: 'default' },
	qualified: { label: 'Qualifié', type: 'warning' },
	negotiation: { label: 'Négociation', type: 'info' },
	converted: { label: 'Converti', type: 'success' },
}

const filteredProspects = computed(() => {
	let result = prospects.value
	if (searchQuery.value) {
		const query = searchQuery.value.toLowerCase()
		result = result.filter(p => 
			(p.company || '').toLowerCase().includes(query) ||
			(p.contact || '').toLowerCase().includes(query) ||
			(p.email || '').toLowerCase().includes(query)
		)
	}
	if (filterStatus.value) {
		result = result.filter(p => p.status === filterStatus.value)
	}
	if (filterSource.value) {
		result = result.filter(p => p.source_id === filterSource.value)
	}
	return result
})

const pagination = {
	pageSize: 10,
}

const formatValue = (value: number) => {
	return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(value)
}

const formatDate = (timestamp: number) => {
	return format(new Date(timestamp), 'dd MMM yyyy', { locale: fr })
}

const columns = [
	{
		title: 'Entreprise',
		key: 'company',
		width: 200,
		render: (row: any) => (
			<div class="flex items-center gap-12px">
				<div class="w-36px h-36px rounded-10px bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center text-white font-600 text-12px">
					{(row.company || row.email || '?').split(' ').map((n: string) => n[0]).join('').substring(0, 2).toUpperCase()}
				</div>
				<div>
					<div class="font-600 text-14px">{row.company || '-'}</div>
					<div class="text-12px text-gray-400">{row.contact || '-'}</div>
				</div>
			</div>
		),
	},
	{
		title: 'Email',
		key: 'email',
		width: 220,
	},
	{
		title: 'Source',
		key: 'source_name',
		width: 130,
		render: (row: any) => row.source_name ? <NTag size="small" bordered={false}>{row.source_name}</NTag> : '-',
	},
	{
		title: 'Valeur',
		key: 'value',
		width: 120,
		render: (row: any) => <span class="font-600 text-green-600">{formatValue(row.value || 0)}</span>,
	},
	{
		title: 'Score',
		key: 'score',
		width: 140,
		render: (row: any) => <NRate value={row.score || 0} readonly size="small" />,
	},
	{
		title: 'Statut',
		key: 'status',
		width: 130,
		render: (row: any) => {
			const config = statusConfig[row.status] || statusConfig.new
			return <NTag type={config.type} size="small" round>{config.label}</NTag>
		},
	},
	{
		title: 'Tags',
		key: 'tags',
		width: 160,
		render: (row: any) => (
			<NFlex size="small">
				{(row.tags || []).slice(0, 2).map((tag: string) => (
					<NTag key={tag} size="tiny" bordered={false}>{tag}</NTag>
				))}
			</NFlex>
		),
	},
	{
		title: 'Dernier contact',
		key: 'last_contact',
		width: 140,
		render: (row: any) => row.last_contact ? formatDate(row.last_contact * 1000) : '--',
	},
	{
		title: 'Actions',
		key: 'actions',
		width: 120,
		align: 'center' as const,
		render: (row: any) => (
			<NFlex justify="center" size="small">
				<NButton text type="primary">
					<i class="i-mdi-eye-outline text-18px"></i>
				</NButton>
				<NButton text type="info">
					<i class="i-mdi-email-outline text-18px"></i>
				</NButton>
				<NButton text type="error" onClick={() => handleDelete(row)}>
					<i class="i-mdi-delete-outline text-18px"></i>
				</NButton>
			</NFlex>
		),
	},
]

// Delete function
const handleDelete = (row: any) => {
	dialog.warning({
		title: 'Confirmer la suppression',
		content: `Êtes-vous sûr de vouloir supprimer le prospect "${row.company || row.email}" ?`,
		positiveText: 'Supprimer',
		negativeText: 'Annuler',
		onPositiveClick: async () => {
			try {
				console.log('Deleting prospect with id:', row.id)
				const result = await deleteProspects({ ids: [row.id] })
				console.log('Delete result:', result)
				message.success('Prospect supprimé avec succès')
				loadProspects()
			} catch (error: any) {
				console.error('Failed to delete prospect:', error)
				const errorMsg = error?.response?.data?.msg || error?.msg || error?.message || 'Erreur lors de la suppression'
				message.error(errorMsg)
			}
		},
	})
}

// Export function
const handleExport = async () => {
	if (filteredProspects.value.length === 0) {
		message.warning('Aucun prospect à exporter')
		return
	}
	
	exporting.value = true
	try {
		// Create CSV content
		const headers = ['Entreprise', 'Contact', 'Email', 'Téléphone', 'Source', 'Valeur', 'Score', 'Statut', 'Tags', 'Notes', 'Dernier contact', 'Date création']
		const rows = filteredProspects.value.map((p: any) => [
			p.company || '',
			p.contact || '',
			p.email || '',
			p.phone || '',
			p.source_name || '',
			p.value || 0,
			p.score || 0,
			statusConfig[p.status]?.label || p.status || '',
			(p.tags || []).join(';'),
			p.notes || '',
			p.last_contact ? formatDate(p.last_contact * 1000) : '',
			p.create_time ? formatDate(p.create_time * 1000) : ''
		])
		
		// Build CSV string with proper escaping
		const csvContent = [
			headers.join(';'),
			...rows.map(row => row.map((cell: any) => {
				const str = String(cell)
				// Escape quotes and wrap in quotes if contains semicolon or newline
				if (str.includes(';') || str.includes('"') || str.includes('\n')) {
					return `"${str.replace(/"/g, '""')}"`
				}
				return str
			}).join(';'))
		].join('\n')
		
		// Add BOM for Excel UTF-8 compatibility
		const BOM = '\uFEFF'
		const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' })
		
		// Download file
		const url = window.URL.createObjectURL(blob)
		const link = document.createElement('a')
		link.href = url
		link.setAttribute('download', `prospects_export_${new Date().toISOString().slice(0,10)}.csv`)
		document.body.appendChild(link)
		link.click()
		document.body.removeChild(link)
		window.URL.revokeObjectURL(url)
		
		message.success(`${filteredProspects.value.length} prospects exportés avec succès`)
	} catch (error) {
		console.error('Export failed:', error)
		message.error('Erreur lors de l\'export')
	} finally {
		exporting.value = false
	}
}

// Load functions
const loadProspects = async () => {
	loading.value = true
	try {
		console.log('Loading prospects list...')
		const res = await getProspectList({ page: 1, page_size: 1000 })
		console.log('Load prospects response:', res)
		if (res?.list) {
			prospects.value = res.list
			console.log(`Loaded ${prospects.value.length} prospects`)
		} else {
			console.warn('No prospects list in response:', res)
		}
	} catch (error: any) {
		console.error('Failed to load prospects:', error)
		console.error('Error details:', error?.response?.data || error?.data || error)
		const errorMsg = error?.response?.data?.msg || error?.msg || error?.message || 'Erreur lors du chargement des prospects'
		message.error(errorMsg)
	} finally {
		loading.value = false
	}
}

const loadSources = async () => {
	try {
		const res = await getSourceAll()
		if (res?.list) {
			sources.value = res.list
		}
	} catch (error) {
		console.error('Failed to load sources:', error)
	}
}

const handleImportSuccess = () => {
	message.success('Import réussi !')
	loadProspects()
}

// Load on mount
onMounted(() => {
	loadProspects()
	loadSources()
})
</script>

<style lang="scss" scoped>
.list-container {
	padding: 0;
}

.list-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	margin-bottom: 24px;
}

.header-right {
	display: flex;
	gap: 12px;
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
</style>
