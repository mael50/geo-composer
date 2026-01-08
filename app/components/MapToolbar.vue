```html
<template>
    <div class="absolute top-4 left-4 flex flex-col gap-2 z-[2000]">
        <UTooltip text="Mode Pinceau (Dessiner pour sélectionner)" :shortcuts="['B']">
            <UButton :color="isBrushActive ? 'primary' : 'neutral'" :variant="isBrushActive ? 'solid' : 'solid'"
                icon="i-heroicons-paint-brush" size="md" class="shadow-md" @click="$emit('toggle-brush')" />
        </UTooltip>

        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md flex flex-col p-1 gap-1">
            <UTooltip text="Zoomer">
                <UButton icon="i-heroicons-plus" color="neutral" variant="ghost" size="sm" @click="$emit('zoom-in')" />
            </UTooltip>
            <UTooltip text="Dézoomer">
                <UButton icon="i-heroicons-minus" color="neutral" variant="ghost" size="sm"
                    @click="$emit('zoom-out')" />
            </UTooltip>
        </div>

        <!-- Search Commune -->
        <div class="absolute left-14 top-0 w-64 bg-white dark:bg-gray-900 rounded-lg shadow-lg"
            v-if="departmentsLoaded">
            <USelectMenu v-model="searchedCommune" :items="searchableCommunes" searchable
                placeholder="Aller à une commune..." icon="i-heroicons-magnifying-glass" class="w-64"
                @update:model-value="onCommuneSelect" />
        </div>
    </div>
</template>

<script setup lang="ts">
const props = defineProps<{
    isBrushActive: boolean
    departmentsLoaded: boolean
    allFeatures: any[]
}>()

const emit = defineEmits(['toggle-brush', 'zoom-in', 'zoom-out', 'fly-to'])

const searchedCommune = ref<any>(null)

// Computed for searchable communes from loaded features
const searchableCommunes = computed(() => {
    // Limit to avoid massive list if needed, or rely on USelectMenu virtual scroll if efficient
    // Map features to label/value
    return props.allFeatures.map((f: any) => ({
        label: `${f.properties.nom} (${f.properties.code})`,
        value: f.properties.code,
        center: f.properties.center || null, // We might need to compute center if not available
        feature: f
    })).sort((a: any, b: any) => a.label.localeCompare(b.label))
})

const onCommuneSelect = (item: any) => {
    if (item && item.feature) {
        emit('fly-to', item.feature)
        searchedCommune.value = null
    }
}
</script>
