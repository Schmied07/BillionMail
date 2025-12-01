import { instance } from '@/api'
import { i18n } from '@/i18n'

const { t } = i18n.global

// ========== Source APIs ==========

export const getSourceList = (params: { page?: number; page_size?: number; keyword?: string }) => {
	return instance.get('/prospect/source/list', { params })
}

export const getSourceAll = () => {
	return instance.get('/prospect/source/all')
}

export const createSource = (data: {
	name: string
	default_value: number
	description?: string
	color?: string
}) => {
	return instance.post('/prospect/source/create', data, {
		fetchOptions: {
			loading: t('prospects.loading.createSource'),
			successMessage: true,
		},
	})
}

export const updateSource = (data: {
	id: number
	name?: string
	default_value?: number
	description?: string
	color?: string
}) => {
	return instance.post('/prospect/source/update', data, {
		fetchOptions: {
			loading: t('prospects.loading.updateSource'),
			successMessage: true,
		},
	})
}

export const deleteSource = (data: { id: number }) => {
	return instance.post('/prospect/source/delete', data, {
		fetchOptions: {
			loading: t('prospects.loading.deleteSource'),
			successMessage: true,
		},
	})
}

// ========== Prospect APIs ==========

export interface ProspectListParams {
	page?: number
	page_size?: number
	keyword?: string
	status?: string
	source_id?: number
	sort_by?: string
	sort_order?: string
}

export const getProspectList = (params: ProspectListParams) => {
	return instance.get('/prospect/list', { params })
}

export const getProspect = (params: { id: number }) => {
	return instance.get('/prospect/get', { params })
}

export const createProspect = (data: {
	company: string
	contact: string
	email: string
	phone?: string
	value?: number
	score?: number
	status?: string
	tags?: string[]
	notes?: string
	source_id: number
}) => {
	return instance.post('/prospect/create', data, {
		fetchOptions: {
			loading: t('prospects.loading.createProspect'),
			successMessage: true,
		},
	})
}

export const updateProspect = (data: {
	id: number
	company?: string
	contact?: string
	email?: string
	phone?: string
	value?: number
	score?: number
	status?: string
	tags?: string[]
	notes?: string
	source_id?: number
	last_contact?: number
}) => {
	return instance.post('/prospect/update', data, {
		fetchOptions: {
			loading: t('prospects.loading.updateProspect'),
			successMessage: true,
		},
	})
}

export const deleteProspects = (data: { ids: number[] }) => {
	return instance.post('/prospect/delete', data, {
		fetchOptions: {
			loading: t('prospects.loading.deleteProspect'),
			successMessage: true,
		},
	})
}

export const getProspectStats = () => {
	return instance.get('/prospect/stats')
}

// ========== Import APIs ==========

export interface FieldMapping {
	csv_column: string
	app_field: string
}

export const importPreview = (data: { file_data: string; delimiter?: string }) => {
	return instance.post('/prospect/import/preview', data, {
		fetchOptions: {
			loading: t('prospects.loading.preview'),
		},
	})
}

export const importProspects = (data: {
	source_id: number
	file_data: string
	delimiter?: string
	mapping: FieldMapping[]
	default_status?: string
	default_score?: number
}) => {
	return instance.post('/prospect/import', data, {
		fetchOptions: {
			loading: t('prospects.loading.import'),
			successMessage: true,
		},
	})
}
