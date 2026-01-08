<template>
    <aside
        class="w-80 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-800 flex flex-col h-full shadow-lg z-20">
        <div class="p-4 border-b border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-950">
            <h2 class="text-sm font-bold uppercase text-gray-500 dark:text-gray-400 mb-4 tracking-wider">Données</h2>
            <div class="space-y-4">
                <UFormField label="Charger un Département">
                    <USelectMenu v-model="selectedDep" :items="departments" placeholder="Rechercher..."
                        class="w-full" />
                </UFormField>
                <UButton block :loading="loading" :disabled="!selectedDep" @click="emitLoad" color="primary"
                    variant="solid" icon="i-heroicons-cloud-arrow-down">
                    Charger les données
                </UButton>
            </div>
        </div>

        <div class="flex-1 overflow-y-auto p-4 space-y-6">
            <!-- Loaded Zones -->
            <div v-if="loadedDeps.length > 0">
                <h3 class="text-xs font-semibold uppercase text-gray-500 mb-3 flex justify-between items-center">
                    Zones Actives
                    <UButton size="xs" color="error" variant="link" @click="$emit('clear-map')">Tout effacer</UButton>
                </h3>
                <div class="space-y-2">
                    <UCard v-for="depCode in loadedDeps" :key="depCode">
                        <div class="flex justify-between items-center">
                            <div class="flex items-center gap-2">
                                <UIcon name="i-heroicons-map" class="text-primary-500" />
                                <span class="font-medium text-sm">{{ getDepName(depCode) }}</span>
                            </div>
                            <UTooltip text="Sélectionner tout">
                                <UButton size="xs" color="neutral" variant="ghost" icon="i-heroicons-check-circle"
                                    @click="$emit('select-all-dep', depCode)" />
                            </UTooltip>
                            <UTooltip text="Retirer ce département">
                                <UButton size="xs" color="error" variant="ghost" icon="i-heroicons-trash"
                                    @click="$emit('remove-dep', depCode)" />
                            </UTooltip>
                        </div>
                    </UCard>
                </div>
            </div>

            <!-- Selection Stats -->
            <div>
                <h3 class="text-xs font-semibold uppercase text-gray-500 mb-3 flex justify-between items-center">
                    Ma Sélection
                    <span v-if="selectedCount > 0" class="text-primary-600 font-bold">{{ selectedCount }}</span>
                </h3>

                <div v-if="selectedCount > 0" class="space-y-3">
                    <div
                        class="p-3 bg-primary-50 dark:bg-primary-900/10 rounded-lg border border-primary-100 dark:border-primary-800 space-y-2">
                        <p class="text-xs text-primary-700 dark:text-primary-300 mb-2">
                            Communes sélectionnées pour l'export.
                        </p>
                        <UButton size="xs" color="primary" variant="solid" block icon="i-heroicons-check-circle"
                            @click="$emit('select-all')">
                            Tout sélectionner (visible)
                        </UButton>
                        <UButton size="xs" color="error" variant="soft" block icon="i-heroicons-trash"
                            @click="$emit('clear-selection')">
                            Vider la sélection
                        </UButton>
                    </div>

                    <!-- Search within selection (Future feature?) -->
                    <!-- <UInput placeholder="Rechercher dans la sélection..." icon="i-heroicons-magnifying-glass" size="xs" /> -->
                </div>
                <div v-else class="text-sm text-gray-400 text-center py-8 italic flex flex-col items-center gap-4">
                    <span>Aucune commune sélectionnée.</span>
                    <UButton v-if="loadedDeps.length > 0" size="xs" color="primary" variant="outline"
                        icon="i-heroicons-check-circle" @click="$emit('select-all')">
                        Tout sélectionner
                    </UButton>
                    <span class="text-xs">Cliquez sur la carte ou utilisez le pinceau.</span>
                </div>
            </div>
        </div>

        <div class="p-4 border-t border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-950">
            <UButton block size="lg" icon="i-heroicons-arrow-down-tray" :disabled="selectedCount === 0"
                @click="$emit('download')" color="success" variant="solid">
                Exporter GeoJSON
            </UButton>
        </div>
    </aside>
</template>

<script setup lang="ts">
const props = defineProps<{
    departments: any[]
    loadedDeps: string[]
    selectedCount: number
    loading: boolean
}>()

const emit = defineEmits(['load-dep', 'select-all-dep', 'remove-dep', 'select-all', 'clear-map', 'clear-selection', 'download'])

const selectedDep = ref<any>(null)

const emitLoad = () => {
    if (selectedDep.value) {
        emit('load-dep', selectedDep.value)
        selectedDep.value = null // Reset after load attempt
    }
}

const getDepName = (code: string) => {
    const dep = props.departments.find(d => d.code === code)
    return dep ? `${dep.nom} (${code})` : code
}
</script>
