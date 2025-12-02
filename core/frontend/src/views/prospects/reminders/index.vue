<template>
	<div class="reminders-container">
		<div class="reminders-header">
			<div class="header-left">
				<h2 class="page-title">
					<i class="i-mdi-bell-ring-outline mr-12px"></i>
					Rappels & Relances
				</h2>
				<p class="page-subtitle">Planifiez vos suivis et ne manquez aucune opportunité</p>
			</div>
			<div class="header-right">
				<n-button type="primary" @click="showAddModal = true">
					<template #icon>
						<i class="i-mdi-plus"></i>
					</template>
					Nouveau Rappel
				</n-button>
			</div>
		</div>

		<!-- Loading State -->
		<div v-if="loading" class="loading-container">
			<n-spin size="large">
				<div style="height: 200px;"></div>
			</n-spin>
		</div>

		<!-- Stats -->
		<div v-else class="reminder-stats">
			<div class="stat-card urgent">
				<div class="stat-icon">
					<i class="i-mdi-alert-circle"></i>
				</div>
				<div class="stat-info">
					<span class="stat-value">{{ overdueReminders.length }}</span>
					<span class="stat-label">En retard</span>
				</div>
			</div>
			<div class="stat-card today">
				<div class="stat-icon">
					<i class="i-mdi-calendar-today"></i>
				</div>
				<div class="stat-info">
					<span class="stat-value">{{ todayReminders.length }}</span>
					<span class="stat-label">Aujourd'hui</span>
				</div>
			</div>
			<div class="stat-card upcoming">
				<div class="stat-icon">
					<i class="i-mdi-calendar-week"></i>
				</div>
				<div class="stat-info">
					<span class="stat-value">{{ upcomingReminders.length }}</span>
					<span class="stat-label">Cette semaine</span>
				</div>
			</div>
			<div class="stat-card completed">
				<div class="stat-icon">
					<i class="i-mdi-check-circle"></i>
				</div>
				<div class="stat-info">
					<span class="stat-value">{{ completedReminders.length }}</span>
					<span class="stat-label">Complétés</span>
				</div>
			</div>
		</div>

		<!-- Reminders List -->
		<div v-if="!loading" class="reminders-sections">
			<!-- Overdue -->
			<div class="section" v-if="overdueReminders.length > 0">
				<h3 class="section-title urgent">
					<i class="i-mdi-alert-circle"></i>
					En retard
				</h3>
				<div class="reminder-list">
					<div class="reminder-card urgent" v-for="reminder in overdueReminders" :key="reminder.id">
						<div class="reminder-checkbox">
							<n-checkbox v-model:checked="reminder.completed" @update:checked="toggleReminder(reminder)" />
						</div>
						<div class="reminder-content">
							<div class="reminder-title">{{ reminder.title }}</div>
							<div class="reminder-meta">
								<span class="prospect-name">
									<i class="i-mdi-account"></i>
									{{ reminder.prospectName }}
								</span>
								<span class="reminder-date">
									<i class="i-mdi-clock-outline"></i>
									{{ formatDate(reminder.dueDate) }}
								</span>
							</div>
						</div>
						<div class="reminder-actions">
							<n-button text type="primary" @click="rescheduleReminder(reminder)">
								<i class="i-mdi-calendar-clock"></i>
							</n-button>
							<n-button text type="error" @click="deleteReminder(reminder)">
								<i class="i-mdi-delete-outline"></i>
							</n-button>
						</div>
					</div>
				</div>
			</div>

			<!-- Today -->
			<div class="section" v-if="todayReminders.length > 0">
				<h3 class="section-title today">
					<i class="i-mdi-calendar-today"></i>
					Aujourd'hui
				</h3>
				<div class="reminder-list">
					<div class="reminder-card" v-for="reminder in todayReminders" :key="reminder.id">
						<div class="reminder-checkbox">
							<n-checkbox v-model:checked="reminder.completed" @update:checked="toggleReminder(reminder)" />
						</div>
						<div class="reminder-content">
							<div class="reminder-title">{{ reminder.title }}</div>
							<div class="reminder-meta">
								<span class="prospect-name">
									<i class="i-mdi-account"></i>
									{{ reminder.prospectName }}
								</span>
								<span class="reminder-type">
									<n-tag :type="getTypeConfig(reminder.type).type" size="tiny">{{ getTypeConfig(reminder.type).label }}</n-tag>
								</span>
							</div>
						</div>
						<div class="reminder-actions">
							<n-button text type="error" @click="deleteReminder(reminder)">
								<i class="i-mdi-delete-outline"></i>
							</n-button>
						</div>
					</div>
				</div>
			</div>

			<!-- Upcoming -->
			<div class="section" v-if="upcomingReminders.length > 0">
				<h3 class="section-title upcoming">
					<i class="i-mdi-calendar-week"></i>
					Cette semaine
				</h3>
				<div class="reminder-list">
					<div class="reminder-card" v-for="reminder in upcomingReminders" :key="reminder.id">
						<div class="reminder-checkbox">
							<n-checkbox v-model:checked="reminder.completed" @update:checked="toggleReminder(reminder)" />
						</div>
						<div class="reminder-content">
							<div class="reminder-title">{{ reminder.title }}</div>
							<div class="reminder-meta">
								<span class="prospect-name">
									<i class="i-mdi-account"></i>
									{{ reminder.prospectName }}
								</span>
								<span class="reminder-date">
									<i class="i-mdi-clock-outline"></i>
									{{ formatDate(reminder.dueDate) }}
								</span>
							</div>
						</div>
						<div class="reminder-actions">
							<n-button text type="error" @click="deleteReminder(reminder)">
								<i class="i-mdi-delete-outline"></i>
							</n-button>
						</div>
					</div>
				</div>
			</div>

			<!-- Empty State -->
			<div class="empty-state" v-if="activeReminders.length === 0">
				<i class="i-mdi-bell-check-outline"></i>
				<h3>Aucun rappel actif</h3>
				<p>Créez un rappel pour ne manquer aucune opportunité</p>
			</div>
		</div>

		<!-- Add Reminder Modal -->
		<n-modal v-model:show="showAddModal" preset="card" title="Nouveau Rappel" style="width: 500px;">
			<n-form :model="formData" label-placement="top">
				<n-form-item label="Titre">
					<n-input v-model:value="formData.title" placeholder="Ex: Relancer pour devis" />
				</n-form-item>
				<n-form-item label="Prospect">
					<n-select v-model:value="formData.prospectId" :options="prospectOptions" placeholder="Sélectionner un prospect" />
				</n-form-item>
				<n-form-item label="Type">
					<n-select v-model:value="formData.type" :options="typeOptions" placeholder="Type de rappel" />
				</n-form-item>
				<n-form-item label="Date">
					<n-date-picker v-model:value="formData.dueDate" type="datetime" style="width: 100%;" />
				</n-form-item>
				<n-form-item label="Notes">
					<n-input v-model:value="formData.notes" type="textarea" placeholder="Notes additionnelles..." :rows="2" />
				</n-form-item>
			</n-form>
			<template #footer>
				<div class="modal-footer">
					<n-button @click="showAddModal = false" :disabled="loading">Annuler</n-button>
					<n-button type="primary" @click="addReminder" :loading="loading">Créer</n-button>
				</div>
			</template>
		</n-modal>
	</div>
</template>

<script lang="ts" setup>
import { format, isToday, isPast, isThisWeek } from 'date-fns'
import { fr } from 'date-fns/locale'
import { useMessage } from 'naive-ui'
import { getReminderList, createReminder, updateReminder, deleteReminders, getProspectList } from '@/api/modules/prospects'

const message = useMessage()

interface Reminder {
	id: number
	title: string
	prospectId: number
	prospectName: string
	type: string
	dueDate: number
	notes?: string
	completed: boolean
	prospect?: {
		company?: string
		contact?: string
		email?: string
	}
}

const showAddModal = ref(false)
const loading = ref(false)
const reminders = ref<Reminder[]>([])
const prospects = ref<any[]>([])

const formData = reactive({
	title: '',
	prospectId: null as number | null,
	type: 'call',
	dueDate: Date.now(),
	notes: '',
})

const typeOptions = [
	{ label: 'Appel', value: 'call' },
	{ label: 'Email', value: 'email' },
	{ label: 'Réunion', value: 'meeting' },
	{ label: 'Autre', value: 'other' },
]

const prospectOptions = computed(() =>
	prospects.value.map((p) => ({
		label: p.company || p.contact || p.email,
		value: p.id,
	}))
)

const typeConfig: Record<string, { label: string; type: 'info' | 'warning' | 'success' | 'error' | 'default' }> = {
	call: { label: 'Appel', type: 'info' },
	email: { label: 'Email', type: 'default' },
	meeting: { label: 'Réunion', type: 'warning' },
	other: { label: 'Autre', type: 'default' },
}

const getTypeConfig = (type: string) => typeConfig[type] || typeConfig.other

const activeReminders = computed(() => reminders.value.filter(r => !r.completed))
const completedReminders = computed(() => reminders.value.filter(r => r.completed))

const overdueReminders = computed(() => 
	activeReminders.value.filter(r => isPast(new Date(r.dueDate)) && !isToday(new Date(r.dueDate)))
)

const todayReminders = computed(() => 
	activeReminders.value.filter(r => isToday(new Date(r.dueDate)))
)

const upcomingReminders = computed(() => 
	activeReminders.value.filter(r => !isPast(new Date(r.dueDate)) && !isToday(new Date(r.dueDate)) && isThisWeek(new Date(r.dueDate)))
)

const formatDate = (timestamp: number) => {
	return format(new Date(timestamp), 'dd MMM à HH:mm', { locale: fr })
}

// Load data functions
const loadReminders = async () => {
	try {
		loading.value = true
		const response = await getReminderList({})
		if (response.success) {
			reminders.value = response.data.map((reminder: any) => ({
				...reminder,
				prospectName: reminder.prospect?.company || reminder.prospect?.contact || reminder.prospect?.email || 'Prospect inconnu'
			}))
		}
	} catch (error) {
		console.error('Erreur lors du chargement des rappels:', error)
		message.error('Erreur lors du chargement des rappels')
	} finally {
		loading.value = false
	}
}

const loadProspects = async () => {
	try {
		const response = await getProspectList({})
		if (response.success) {
			prospects.value = response.data
		}
	} catch (error) {
		console.error('Erreur lors du chargement des prospects:', error)
	}
}

const toggleReminder = async (reminder: Reminder) => {
	try {
		const response = await updateReminder({
			id: reminder.id,
			completed: reminder.completed
		})
		if (!response.success) {
			// Revert on error
			reminder.completed = !reminder.completed
			message.error('Erreur lors de la mise à jour du rappel')
		}
	} catch (error) {
		// Revert on error
		reminder.completed = !reminder.completed
		console.error('Erreur lors de la mise à jour du rappel:', error)
		message.error('Erreur lors de la mise à jour du rappel')
	}
}

const rescheduleReminder = (reminder: Reminder) => {
	// Open reschedule modal - to be implemented
	message.info('Fonctionnalité de reprogrammation à venir')
}

const deleteReminder = async (reminder: Reminder) => {
	try {
		const response = await deleteReminders({ ids: [reminder.id] })
		if (response.success) {
			reminders.value = reminders.value.filter(r => r.id !== reminder.id)
			message.success('Rappel supprimé')
		} else {
			message.error('Erreur lors de la suppression du rappel')
		}
	} catch (error) {
		console.error('Erreur lors de la suppression du rappel:', error)
		message.error('Erreur lors de la suppression du rappel')
	}
}

const addReminder = async () => {
	try {
		if (!formData.title || !formData.prospectId) {
			message.warning('Veuillez remplir tous les champs obligatoires')
			return
		}

		loading.value = true
		const response = await createReminder({
			title: formData.title,
			prospect_id: formData.prospectId,
			type: formData.type,
			due_date: formData.dueDate,
			notes: formData.notes
		})

		if (response.success) {
			message.success('Rappel créé avec succès')
			showAddModal.value = false
			Object.assign(formData, { title: '', prospectId: null, type: 'call', dueDate: Date.now(), notes: '' })
			await loadReminders() // Reload to get updated data
		} else {
			message.error('Erreur lors de la création du rappel')
		}
	} catch (error) {
		console.error('Erreur lors de la création du rappel:', error)
		message.error('Erreur lors de la création du rappel')
	} finally {
		loading.value = false
	}
}

// Initialize data on mount
onMounted(async () => {
	await Promise.all([loadReminders(), loadProspects()])
})
</script>

<style lang="scss" scoped>
.reminders-container {
	padding: 0;
}

.loading-container {
	display: flex;
	justify-content: center;
	align-items: center;
	min-height: 300px;
}

.reminders-header {
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

.reminder-stats {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 16px;
	margin-bottom: 32px;
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

	&.urgent .stat-icon {
		background: linear-gradient(135deg, #ef4444, #f87171);
	}
	&.today .stat-icon {
		background: linear-gradient(135deg, #3b82f6, #60a5fa);
	}
	&.upcoming .stat-icon {
		background: linear-gradient(135deg, #8b5cf6, #a78bfa);
	}
	&.completed .stat-icon {
		background: linear-gradient(135deg, #10b981, #34d399);
	}
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
	font-size: 28px;
	font-weight: 700;
	color: var(--color-text-1);
}

.stat-label {
	font-size: 13px;
	color: var(--color-text-3);
}

.section {
	margin-bottom: 32px;
}

.section-title {
	display: flex;
	align-items: center;
	gap: 8px;
	font-size: 16px;
	font-weight: 600;
	margin: 0 0 16px 0;

	&.urgent {
		color: #ef4444;
	}
	&.today {
		color: #3b82f6;
	}
	&.upcoming {
		color: #8b5cf6;
	}
}

.reminder-list {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.reminder-card {
	display: flex;
	align-items: center;
	gap: 16px;
	padding: 16px 20px;
	background: var(--color-bg-1);
	border-radius: 12px;
	box-shadow: var(--shadow-sm);
	border: 1px solid var(--color-border-1);
	transition: all 0.2s ease;

	&:hover {
		box-shadow: var(--shadow-md);
	}

	&.urgent {
		border-left: 4px solid #ef4444;
	}
}

.reminder-content {
	flex: 1;
}

.reminder-title {
	font-size: 15px;
	font-weight: 600;
	color: var(--color-text-1);
	margin-bottom: 4px;
}

.reminder-meta {
	display: flex;
	align-items: center;
	gap: 16px;
	font-size: 13px;
	color: var(--color-text-3);

	i {
		margin-right: 4px;
	}
}

.reminder-actions {
	display: flex;
	gap: 8px;
}

.empty-state {
	text-align: center;
	padding: 60px 20px;
	color: var(--color-text-3);

	i {
		font-size: 64px;
		margin-bottom: 16px;
		opacity: 0.5;
	}

	h3 {
		margin: 0 0 8px;
		color: var(--color-text-2);
	}

	p {
		margin: 0;
	}
}

.modal-footer {
	display: flex;
	justify-content: flex-end;
	gap: 12px;
}
</style>
