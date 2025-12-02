<template>
	<n-modal v-model:show="showModal" preset="card" :title="t('prospects.import.title')" style="width: 900px; max-width: 95vw;">
		<n-steps :current="currentStep" class="mb-24px">
			<n-step :title="t('prospects.import.step1')">
				<template #icon><i class="i-mdi-cloud-upload"></i></template>
			</n-step>
			<n-step :title="t('prospects.import.step2')">
				<template #icon><i class="i-mdi-link-variant"></i></template>
			</n-step>
			<n-step :title="t('prospects.import.step3')">
				<template #icon><i class="i-mdi-eye"></i></template>
			</n-step>
		</n-steps>

		<!-- Step 1: Upload File & Select Source -->
		<div v-show="currentStep === 1" class="step-content">
			<n-form ref="step1FormRef" :model="formData" :rules="step1Rules" label-placement="top">
				<n-form-item :label="t('prospects.import.source')" path="source_id">
					<n-select
						v-model:value="formData.source_id"
						:options="sourceOptions"
						:placeholder="t('prospects.import.selectSource')"
						:loading="loadingSources"
						filterable
					>
						<template #action>
							<n-button text type="primary" @click="showSourceModal = true">
								<template #icon><i class="i-mdi-plus"></i></template>
								{{ t('prospects.import.newSource') }}
							</n-button>
						</template>
					</n-select>
				</n-form-item>

				<n-form-item v-if="selectedSource" :label="t('prospects.import.sourceInfo')">
					<n-card size="small" class="source-info-card">
						<div class="source-info">
							<div class="source-color" :style="{ background: selectedSource.color }"></div>
							<div class="source-details">
								<div class="source-name">{{ selectedSource.name }}</div>
								<div class="source-value">
									{{ t('prospects.import.defaultValue') }}: {{ formatCurrency(selectedSource.default_value) }}
								</div>
								<div v-if="selectedSource.description" class="source-description">
									{{ selectedSource.description }}
								</div>
							</div>
						</div>
					</n-card>
				</n-form-item>

				<n-form-item :label="t('prospects.import.file')" path="file">
					<n-upload
						:max="1"
						accept=".csv"
						:default-upload="false"
						@change="handleFileChange"
					>
						<n-upload-dragger>
							<div class="upload-content">
								<i class="i-mdi-file-delimited-outline upload-icon"></i>
								<p class="upload-text">{{ t('prospects.import.dragOrClick') }}</p>
								<p class="upload-hint">{{ t('prospects.import.csvOnly') }}</p>
							</div>
						</n-upload-dragger>
					</n-upload>
				</n-form-item>

				<n-form-item v-if="fileUploaded" :label="t('prospects.import.delimiter')">
					<n-radio-group v-model:value="formData.delimiter">
						<n-radio value=",">{{ t('prospects.import.comma') }} (,)</n-radio>
						<n-radio value=";">{{ t('prospects.import.semicolon') }} (;)</n-radio>
						<n-radio value="\t">{{ t('prospects.import.tab') }}</n-radio>
					</n-radio-group>
				</n-form-item>
			</n-form>
		</div>

		<!-- Step 2: Field Mapping -->
		<div v-show="currentStep === 2" class="step-content">
			<n-alert type="info" class="mb-16px">
				{{ t('prospects.import.mappingInfo') }}
			</n-alert>

			<div class="mapping-container">
				<div class="mapping-header">
					<div class="csv-col">{{ t('prospects.import.csvColumn') }}</div>
					<div class="arrow"></div>
					<div class="app-col">{{ t('prospects.import.appField') }}</div>
					<div class="sample">{{ t('prospects.import.sampleData') }}</div>
				</div>

				<div v-for="col in csvColumns" :key="col.index" class="mapping-row">
					<div class="csv-col">
						<n-tag size="small">{{ col.name }}</n-tag>
					</div>
					<div class="arrow">
						<i class="i-mdi-arrow-right"></i>
					</div>
					<div class="app-col">
						<n-select
							v-model:value="fieldMappings[col.name]"
							:options="appFieldOptions"
							:placeholder="t('prospects.import.ignore')"
							clearable
							size="small"
						/>
					</div>
					<div class="sample">
						<span class="sample-text">{{ col.sample_data || '-' }}</span>
					</div>
				</div>
			</div>

			<n-divider />

			<n-grid :cols="2" :x-gap="16">
				<n-gi>
					<n-form-item :label="t('prospects.import.defaultStatus')">
						<n-select v-model:value="formData.default_status" :options="statusOptions" />
					</n-form-item>
				</n-gi>
				<n-gi>
					<n-form-item :label="t('prospects.import.defaultScore')">
						<n-rate v-model:value="formData.default_score" />
					</n-form-item>
				</n-gi>
			</n-grid>
		</div>

		<!-- Step 3: Preview & Confirm -->
		<div v-show="currentStep === 3" class="step-content">
			<n-alert type="success" class="mb-16px">
				{{ t('prospects.import.previewInfo', { count: previewData.total_rows }) }}
			</n-alert>

			<n-card :title="t('prospects.import.mappingSummary')" size="small" class="mb-16px">
				<div class="mapping-summary">
					<div v-for="(appField, csvCol) in fieldMappings" :key="csvCol" class="mapping-item">
						<span class="csv-name">{{ csvCol }}</span>
						<i class="i-mdi-arrow-right"></i>
						<n-tag :type="getFieldTagType(appField)" size="small">{{ getFieldLabel(appField) }}</n-tag>
					</div>
				</div>
			</n-card>

			<n-card :title="t('prospects.import.samplePreview')" size="small">
				<n-data-table
					:columns="previewColumns"
					:data="previewTableData"
					:bordered="false"
					:max-height="250"
					size="small"
				/>
			</n-card>

			<n-card :title="t('prospects.import.importSettings')" size="small" class="mt-16px">
				<n-descriptions :column="2">
					<n-descriptions-item :label="t('prospects.import.source')">
						{{ selectedSource?.name }}
					</n-descriptions-item>
					<n-descriptions-item :label="t('prospects.import.defaultValue')">
						{{ formatCurrency(selectedSource?.default_value || 0) }}
					</n-descriptions-item>
					<n-descriptions-item :label="t('prospects.import.defaultStatus')">
						{{ getStatusLabel(formData.default_status) }}
					</n-descriptions-item>
					<n-descriptions-item :label="t('prospects.import.defaultScore')">
						{{ formData.default_score }}/5
					</n-descriptions-item>
				</n-descriptions>
			</n-card>
		</div>

		<template #footer>
			<div class="modal-footer">
				<n-button @click="handleClose">{{ t('common.cancel') }}</n-button>
				<n-button v-if="currentStep > 1" @click="prevStep">{{ t('common.previous') }}</n-button>
				<n-button v-if="currentStep < 3" type="primary" :loading="loading" @click="nextStep">
					{{ t('common.next') }}
				</n-button>
				<n-button v-if="currentStep === 3" type="primary" :loading="loading" @click="handleImport">
					{{ t('prospects.import.startImport') }}
				</n-button>
			</div>
		</template>
	</n-modal>

	<!-- Create Source Modal -->
	<n-modal v-model:show="showSourceModal" preset="card" :title="t('prospects.source.create')" style="width: 500px;">
		<n-form ref="sourceFormRef" :model="sourceForm" :rules="sourceRules" label-placement="top">
			<n-form-item :label="t('prospects.source.name')" path="name">
				<n-input v-model:value="sourceForm.name" :placeholder="t('prospects.source.namePlaceholder')" />
			</n-form-item>
			<n-form-item :label="t('prospects.source.defaultValue')" path="default_value">
				<n-input-number v-model:value="sourceForm.default_value" :min="0" style="width: 100%;">
					<template #suffix>€</template>
				</n-input-number>
			</n-form-item>
			<n-form-item :label="t('prospects.source.color')">
				<div class="color-picker">
					<div
						v-for="color in colorOptions"
						:key="color"
						class="color-option"
						:class="{ active: sourceForm.color === color }"
						:style="{ background: color }"
						@click="sourceForm.color = color"
					></div>
				</div>
			</n-form-item>
			<n-form-item :label="t('prospects.source.description')">
				<n-input v-model:value="sourceForm.description" type="textarea" :rows="2" />
			</n-form-item>
		</n-form>
		<template #footer>
			<div class="modal-footer">
				<n-button @click="showSourceModal = false">{{ t('common.cancel') }}</n-button>
				<n-button type="primary" :loading="creatingSource" @click="handleCreateSource">
					{{ t('common.create') }}
				</n-button>
			</div>
		</template>
	</n-modal>
</template>

<script lang="ts" setup>
import { useI18n } from 'vue-i18n'
import { useMessage } from 'naive-ui'
import { getSourceAll, createSource, importPreview, importProspects } from '@/api/modules/prospects'

const { t } = useI18n()
const message = useMessage()

const props = defineProps<{
	show: boolean
}>()

const emit = defineEmits<{
	(e: 'update:show', value: boolean): void
	(e: 'success'): void
}>()

const showModal = computed({
	get: () => props.show,
	set: (val) => emit('update:show', val),
})

// State
const currentStep = ref(1)
const loading = ref(false)
const loadingSources = ref(false)
const fileUploaded = ref(false)
const fileContent = ref('')

const formData = reactive({
	source_id: null as number | null,
	delimiter: ',',
	default_status: 'new',
	default_score: 3,
})

const sources = ref<any[]>([])
const csvColumns = ref<any[]>([])
const fieldMappings = reactive<Record<string, string>>({})
const previewData = ref<any>({
	total_rows: 0,
	sample_rows: [],
})

// Source modal
const showSourceModal = ref(false)
const creatingSource = ref(false)
const sourceFormRef = ref()
const sourceForm = reactive({
	name: '',
	default_value: 0,
	description: '',
	color: '#3b82f6',
})

const colorOptions = [
	'#3b82f6', '#8b5cf6', '#10b981', '#f59e0b', '#ef4444',
	'#06b6d4', '#ec4899', '#84cc16', '#f97316', '#6366f1',
]

// Computed
const sourceOptions = computed(() =>
	sources.value.map((s) => ({
		label: `${s.name} (${formatCurrency(s.default_value)})`,
		value: s.id,
	}))
)

const selectedSource = computed(() =>
	sources.value.find((s) => s.id === formData.source_id)
)

const statusOptions = [
	{ label: 'Nouveau', value: 'new' },
	{ label: 'Contacté', value: 'contacted' },
	{ label: 'Qualifié', value: 'qualified' },
	{ label: 'Négociation', value: 'negotiation' },
	{ label: 'Converti', value: 'converted' },
]

const appFieldOptions = [
	{ label: t('prospects.fields.email'), value: 'email' },
	{ label: t('prospects.fields.company'), value: 'company' },
	{ label: t('prospects.fields.contact'), value: 'contact' },
	{ label: t('prospects.fields.phone'), value: 'phone' },
	{ label: t('prospects.fields.value'), value: 'value' },
	{ label: t('prospects.fields.score'), value: 'score' },
	{ label: t('prospects.fields.status'), value: 'status' },
	{ label: t('prospects.fields.tags'), value: 'tags' },
	{ label: t('prospects.fields.notes'), value: 'notes' },
]

const step1Rules = {
	source_id: { required: true, type: 'number', message: t('prospects.import.sourceRequired') },
}

const sourceRules = {
	name: { required: true, message: t('prospects.source.nameRequired') },
	default_value: { required: true, type: 'number', message: t('prospects.source.valueRequired') },
}

const previewColumns = computed(() => {
	const cols: any[] = []
	for (const [csvCol, appField] of Object.entries(fieldMappings)) {
		if (appField) {
			cols.push({
				title: getFieldLabel(appField),
				key: csvCol,
				ellipsis: true,
				width: 150,
			})
		}
	}
	return cols
})

const previewTableData = computed(() => {
	const rows: any[] = []
	const columnIndexMap: Record<string, number> = {}
	
	csvColumns.value.forEach((col) => {
		columnIndexMap[col.name] = col.index
	})

	previewData.value.sample_rows?.slice(0, 5).forEach((row: string[], rowIndex: number) => {
		const rowData: any = { key: rowIndex }
		for (const [csvCol, appField] of Object.entries(fieldMappings)) {
			if (appField) {
				const colIndex = columnIndexMap[csvCol]
				rowData[csvCol] = row[colIndex] || ''
			}
		}
		rows.push(rowData)
	})
	return rows
})

// Methods
const formatCurrency = (value: number) => {
	return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(value)
}

const getFieldLabel = (field: string) => {
	const option = appFieldOptions.find((o) => o.value === field)
	return option?.label || field
}

const getFieldTagType = (field: string) => {
	if (field === 'email') return 'error'
	if (['company', 'contact'].includes(field)) return 'info'
	return 'default'
}

const getStatusLabel = (status: string) => {
	const option = statusOptions.find((o) => o.value === status)
	return option?.label || status
}

const loadSources = async () => {
	loadingSources.value = true
	try {
		const res = await getSourceAll()
		if (res?.list) {
			sources.value = res.list
		}
	} catch (error) {
		console.error('Failed to load sources:', error)
	} finally {
		loadingSources.value = false
	}
}

const handleFileChange = (options: { fileList: any[] }) => {
	const file = options.fileList[0]?.file
	if (file) {
		const reader = new FileReader()
		reader.onload = (e) => {
			fileContent.value = e.target?.result as string
			fileUploaded.value = true
		}
		reader.readAsText(file)
	} else {
		fileContent.value = ''
		fileUploaded.value = false
	}
}

const nextStep = async () => {
	if (currentStep.value === 1) {
		// Validate step 1
		if (!formData.source_id) {
			message.warning(t('prospects.import.sourceRequired'))
			return
		}
		if (!fileContent.value) {
			message.warning(t('prospects.import.fileRequired'))
			return
		}

		// Preview CSV
		loading.value = true
		try {
			const res = await importPreview({
				file_data: btoa(unescape(encodeURIComponent(fileContent.value))),
				delimiter: formData.delimiter,
			})
			if (res.data?.data) {
				csvColumns.value = res.data.data.columns || []
				previewData.value = res.data.data

				// Auto-map columns
				autoMapColumns()
			}
			currentStep.value = 2
		} catch (error) {
			message.error(t('prospects.import.previewError'))
		} finally {
			loading.value = false
		}
	} else if (currentStep.value === 2) {
		// Validate mapping - email is required
		if (!Object.values(fieldMappings).includes('email')) {
			message.warning(t('prospects.import.emailRequired'))
			return
		}
		currentStep.value = 3
	}
}

const prevStep = () => {
	if (currentStep.value > 1) {
		currentStep.value--
	}
}

const autoMapColumns = () => {
	// Clear existing mappings
	Object.keys(fieldMappings).forEach((key) => delete fieldMappings[key])

	// Common column name mappings
	const mappings: Record<string, string[]> = {
		email: ['email', 'e-mail', 'mail', 'courriel', 'adresse email', 'adresse e-mail'],
		company: ['company', 'société', 'societe', 'entreprise', 'organization', 'organisation', 'nom entreprise'],
		contact: ['contact', 'nom', 'name', 'fullname', 'full name', 'nom complet', 'prénom nom', 'prenom nom'],
		phone: ['phone', 'téléphone', 'telephone', 'tel', 'mobile', 'numéro', 'numero'],
		value: ['value', 'valeur', 'montant', 'amount', 'budget', 'potential'],
		score: ['score', 'note', 'rating', 'qualité', 'qualite'],
		status: ['status', 'statut', 'état', 'etat', 'stage', 'étape', 'etape'],
		tags: ['tags', 'étiquettes', 'etiquettes', 'labels', 'catégories', 'categories'],
		notes: ['notes', 'commentaires', 'comments', 'remarques', 'description'],
	}

	csvColumns.value.forEach((col) => {
		const colNameLower = col.name.toLowerCase().trim()
		for (const [appField, aliases] of Object.entries(mappings)) {
			if (aliases.some((alias) => colNameLower === alias || colNameLower.includes(alias))) {
				fieldMappings[col.name] = appField
				break
			}
		}
	})
}

const handleImport = async () => {
	loading.value = true
	try {
		const mapping = Object.entries(fieldMappings)
			.filter(([, appField]) => appField)
			.map(([csvCol, appField]) => ({
				csv_column: csvCol,
				app_field: appField,
			}))

		const res = await importProspects({
			source_id: formData.source_id!,
			file_data: btoa(unescape(encodeURIComponent(fileContent.value))),
			delimiter: formData.delimiter,
			mapping,
			default_status: formData.default_status,
			default_score: formData.default_score,
		})

		if (res.data?.data) {
			const { imported_count, skipped_count, error_count } = res.data.data
			message.success(
				t('prospects.import.success', { imported: imported_count, skipped: skipped_count, errors: error_count })
			)
			emit('success')
			handleClose()
		}
	} catch (error) {
		message.error(t('prospects.import.error'))
	} finally {
		loading.value = false
	}
}

const handleCreateSource = async () => {
	const valid = await sourceFormRef.value?.validate()
	if (!valid) return

	creatingSource.value = true
	try {
		const res = await createSource({
			name: sourceForm.name,
			default_value: sourceForm.default_value,
			description: sourceForm.description,
			color: sourceForm.color,
		})
		if (res.data?.data?.id) {
			await loadSources()
			formData.source_id = res.data.data.id
			showSourceModal.value = false
			// Reset form
			sourceForm.name = ''
			sourceForm.default_value = 0
			sourceForm.description = ''
			sourceForm.color = '#3b82f6'
		}
	} catch (error) {
		message.error(t('prospects.source.createError'))
	} finally {
		creatingSource.value = false
	}
}

const handleClose = () => {
	showModal.value = false
	// Reset state
	currentStep.value = 1
	fileUploaded.value = false
	fileContent.value = ''
	csvColumns.value = []
	Object.keys(fieldMappings).forEach((key) => delete fieldMappings[key])
	formData.source_id = null
	formData.delimiter = ','
	formData.default_status = 'new'
	formData.default_score = 3
}

// Watch for modal open
watch(
	() => props.show,
	(val) => {
		if (val) {
			loadSources()
		}
	}
)
</script>

<style lang="scss" scoped>
.step-content {
	min-height: 300px;
}

.upload-content {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 40px 20px;
}

.upload-icon {
	font-size: 48px;
	color: var(--color-primary-1);
	margin-bottom: 16px;
}

.upload-text {
	font-size: 16px;
	color: var(--color-text-1);
	margin: 0 0 8px 0;
}

.upload-hint {
	font-size: 13px;
	color: var(--color-text-3);
	margin: 0;
}

.source-info-card {
	background: var(--color-bg-2);
}

.source-info {
	display: flex;
	align-items: center;
	gap: 16px;
}

.source-color {
	width: 8px;
	height: 48px;
	border-radius: 4px;
}

.source-details {
	flex: 1;
}

.source-name {
	font-weight: 600;
	font-size: 14px;
	color: var(--color-text-1);
}

.source-value {
	font-size: 13px;
	color: var(--color-primary-1);
	margin-top: 4px;
}

.source-description {
	font-size: 12px;
	color: var(--color-text-3);
	margin-top: 4px;
}

.mapping-container {
	border: 1px solid var(--color-border-1);
	border-radius: 8px;
	overflow: hidden;
}

.mapping-header,
.mapping-row {
	display: grid;
	grid-template-columns: 1fr 40px 1fr 150px;
	align-items: center;
	padding: 12px 16px;
	gap: 8px;
}

.mapping-header {
	background: var(--color-bg-2);
	font-weight: 600;
	font-size: 13px;
	color: var(--color-text-2);
}

.mapping-row {
	border-top: 1px solid var(--color-border-1);

	&:hover {
		background: var(--color-bg-2);
	}
}

.arrow {
	display: flex;
	justify-content: center;
	color: var(--color-text-3);
}

.sample-text {
	font-size: 12px;
	color: var(--color-text-3);
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	display: block;
}

.mapping-summary {
	display: flex;
	flex-wrap: wrap;
	gap: 12px;
}

.mapping-item {
	display: flex;
	align-items: center;
	gap: 8px;
	padding: 8px 12px;
	background: var(--color-bg-2);
	border-radius: 6px;
}

.csv-name {
	font-size: 13px;
	color: var(--color-text-2);
}

.modal-footer {
	display: flex;
	justify-content: flex-end;
	gap: 12px;
}

.color-picker {
	display: flex;
	gap: 8px;
	flex-wrap: wrap;
}

.color-option {
	width: 32px;
	height: 32px;
	border-radius: 8px;
	cursor: pointer;
	transition: all 0.2s;
	border: 2px solid transparent;

	&:hover {
		transform: scale(1.1);
	}

	&.active {
		border-color: var(--color-text-1);
		box-shadow: 0 0 0 2px var(--color-bg-1);
	}
}
</style>
