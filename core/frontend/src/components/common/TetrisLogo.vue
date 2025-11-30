<template>
	<div class="tetris-logo" :class="{ 'logo-small': small }">
		<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size">
			<!-- Envelope base -->
			<rect x="4" y="12" width="40" height="28" rx="3" :fill="primaryColor" />
			<!-- Envelope flap -->
			<path d="M4 15L24 28L44 15" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
			<!-- Tetris blocks on top -->
			<rect x="10" y="4" width="8" height="8" rx="1" :fill="accentColor" />
			<rect x="18" y="4" width="8" height="8" rx="1" :fill="secondaryColor" />
			<rect x="26" y="4" width="8" height="8" rx="1" :fill="accentColor" />
			<rect x="18" y="12" width="8" height="4" rx="1" :fill="secondaryColor" opacity="0.8" />
			<!-- Speed lines -->
			<path d="M38 8H42" :stroke="primaryColor" stroke-width="2" stroke-linecap="round" />
			<path d="M36 12H40" :stroke="primaryColor" stroke-width="1.5" stroke-linecap="round" opacity="0.6" />
		</svg>
	</div>
</template>

<script lang="ts" setup>
defineProps({
	size: {
		type: Number,
		default: 40
	},
	small: {
		type: Boolean,
		default: false
	},
	primaryColor: {
		type: String,
		default: '#2563eb'
	},
	secondaryColor: {
		type: String,
		default: '#7c3aed'
	},
	accentColor: {
		type: String,
		default: '#3b82f6'
	}
})
</script>

<style lang="scss" scoped>
.tetris-logo {
	display: flex;
	align-items: center;
	justify-content: center;
	transition: transform 0.2s ease;
	
	&:hover {
		transform: scale(1.05);
	}
	
	&.logo-small {
		transform: scale(0.8);
	}
}
</style>