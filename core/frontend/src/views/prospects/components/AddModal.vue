<template>
	<n-modal v-model:show="showModal" preset="dialog" title="Nouveau Prospect">
		<n-form ref="formRef" :model="formData" :rules="rules" label-placement="top">
			<n-form-item label="Entreprise" path="company">
				<n-input v-model:value="formData.company" placeholder="Nom de l'entreprise" />
			</n-form-item>
			
			<n-grid :cols="2" :x-gap="16">
				<n-form-item-gi label="Prénom" path="firstName">
					<n-input v-model:value="formData.firstName" placeholder="Prénom du contact" />
				</n-form-item-gi>
				<n-form-item-gi label="Nom" path="lastName">
					<n-input v-model:value="formData.lastName" placeholder="Nom du contact" />
				</n-form-item-gi>
			</n-grid>
			
			<n-form-item label="Email" path="email">
				<n-input v-model:value="formData.email" placeholder="email@exemple.com" />
			</n-form-item>
			
			<n-grid :cols="2" :x-gap="16">
				<n-form-item-gi label="Téléphone" path="phone">
					<n-input v-model:value="formData.phone" placeholder="+33 1 23 45 67 89" />
				</n-form-item-gi>
				<n-form-item-gi label="Source" path="source_id">
					<n-select 
						v-model:value="formData.source_id" 
						:options="sourceOptions" 
						placeholder="Sélectionner une source"
						filterable
						clearable
					/>
				</n-form-item-gi>
			</n-grid>
			
			<n-grid :cols="3" :x-gap="16">
				<n-form-item-gi label="Valeur estimée (€)" path="value">
					<n-input-number v-model:value="formData.value" :min="0" placeholder="0" style="width: 100%" />
				</n-form-item-gi>
				<n-form-item-gi label="Score" path="score">
					<n-rate v-model:value="formData.score" />
				</n-form-item-gi>
				<n-form-item-gi label="Statut" path="status">
					<n-select v-model:value="formData.status" :options="statusOptions" placeholder="Statut" />
				</n-form-item-gi>
			</n-grid>
			
			<n-grid :cols="2" :x-gap="16">
				<n-form-item-gi label="Secteur" path="industry">
					<n-select v-model:value="formData.industry" :options="industryOptions" placeholder="Secteur d'activité" />
				</n-form-item-gi>
				<n-form-item-gi label="Taille entreprise" path="company_size">
					<n-select v-model:value="formData.company_size" :options="companySizeOptions" placeholder="Taille" />
				</n-form-item-gi>
			</n-grid>
			
			<n-form-item label="Tags" path="tags">
				<n-dynamic-tags v-model:value="formData.tags" />
			</n-form-item>
			
			<n-form-item label="Notes" path="notes">
				<n-input v-model:value="formData.notes" type="textarea" :rows="3" placeholder="Notes sur le prospect..." />
			</n-form-item>
		</n-form>
		
		<template #action>
			<n-space>
				<n-button @click="handleCancel">Annuler</n-button>
				<n-button type="primary" @click="handleSubmit" :loading="submitting">Ajouter</n-button>
			</n-space>
		</template>
	</n-modal>
</template>

<script lang="ts" setup>
import { ref, computed, watch } from 'vue'
import { useMessage } from 'naive-ui'
import { createProspect, getSourceAll } from '@/api/modules/prospects'

const props = defineProps<{
	show: boolean
}>()

const emit = defineEmits<{
	'update:show': [value: boolean]
	success: []
}>()

const message = useMessage()
const formRef = ref()
const submitting = ref(false)
const sources = ref<any[]>([])

const showModal = computed({
	get: () => props.show,
	set: (value) => emit('update:show', value)
})

const formData = ref({
	company: '',
	firstName: '',
	lastName: '',
	contact: '',
	email: '',
	phone: '',
	source_id: null as number | null,
	value: 0,
	score: 0,
	status: 'new',
	industry: '',
	company_size: '',
	tags: [] as string[],
	notes: ''
})

const rules = {
	email: [
		{ required: true, message: 'L\'email est requis' },
		{ type: 'email', message: 'Format d\'email invalide' }
	],
	source_id: [
		{ required: true, message: 'La source est requise', type: 'number' }
	]
}

const statusOptions = [
	{ label: 'Nouveau', value: 'new' },
	{ label: 'Contacté', value: 'contacted' },
	{ label: 'Qualifié', value: 'qualified' },
	{ label: 'Négociation', value: 'negotiation' },
	{ label: 'Converti', value: 'converted' },
]

const industryOptions = [
	{ label: 'Tech / IT', value: 'tech' },
	{ label: 'Finance', value: 'finance' },
	{ label: 'Industrie', value: 'industrie' },
	{ label: 'Commerce', value: 'retail' },
	{ label: 'Santé', value: 'sante' },
	{ label: 'Services', value: 'services' },
	{ label: 'Immobilier', value: 'immobilier' },
	{ label: 'Éducation', value: 'education' },
	{ label: 'Transport', value: 'transport' },
	{ label: 'Énergie', value: 'energie' },
	{ label: 'Autre', value: 'autre' },
]

const companySizeOptions = [
	{ label: 'TPE', value: 'tpe' },
	{ label: 'PME', value: 'pme' },
	{ label: 'ETI', value: 'eti' },
	{ label: 'GE', value: 'ge' },
]

const sourceOptions = computed(() =>
	sources.value.map((s) => ({
		label: s.name,
		value: s.id,
	}))
)

const resetForm = () => {
	formData.value = {
		company: '',
		firstName: '',
		lastName: '',
		contact: '',
		email: '',
		phone: '',
		source_id: null,
		value: 0,
		score: 0,
		status: 'new',
		industry: '',
		company_size: '',
		tags: [],
		notes: ''
	}
}

const handleCancel = () => {
	showModal.value = false
	resetForm()
}

const handleSubmit = async () => {
	try {
		await formRef.value?.validate()
		submitting.value = true
		
		const payload = {
			...formData.value,
			contact: `${formData.value.firstName} ${formData.value.lastName}`.trim(),
			source_id: formData.value.source_id!,
			tags: formData.value.tags
		}
		
		await createProspect(payload)
		message.success('Prospect créé avec succès')
		emit('success')
		showModal.value = false
		resetForm()
	} catch (error: any) {
		console.error('Failed to create prospect:', error)
		const errorMsg = error?.response?.data?.msg || error?.msg || error?.message || 'Erreur lors de la création'
		message.error(errorMsg)
	} finally {
		submitting.value = false
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

// Load sources when modal opens
watch(() => props.show, (newShow) => {
	if (newShow) {
		loadSources()
	}
})
</script>