<template>
    <div class="h-screen flex flex-col bg-gray-100 dark:bg-gray-950">
        <!-- New Header style optional, simplified as sidebar handles most -->
        <!-- <header class="bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 h-14 flex items-center px-4 justify-between z-10">
            <div class="flex items-center gap-2">
                 <UIcon name="i-heroicons-globe-europe-africa" class="text-primary-500 text-2xl" />
                 <h1 class="font-bold text-gray-800 dark:text-gray-100">Velvet Zones</h1>
            </div>
            <div class="text-xs text-gray-500">v1.0.0</div>
        </header> -->

        <div class="flex-1 flex overflow-hidden relative">
            <!-- Sidebar -->
            <DashboardSidebar :departments="departments" :loaded-deps="loadedDeps"
                :selected-count="selectedCommuneCodes.size" :loading="loading" @load-dep="loadDepartment"
                @select-all-dep="selectAllInDep" @remove-dep="removeDepartment" @select-all="selectAll"
                @clear-map="clearMap" @clear-selection="clearSelection" @download="downloadGeoJson" />

            <!-- Map Area -->
            <main class="flex-1 relative h-full w-full">
                <!-- Floating Toolbar -->
                <MapToolbar :is-brush-active="isBrushMode" :departments-loaded="loadedDeps.length > 0"
                    :all-features="loadedFeatures" @toggle-brush="isBrushMode = !isBrushMode"
                    @zoom-in="mapRef?.zoomIn()" @zoom-out="mapRef?.zoomOut()" @fly-to="flyToCommune" />

                <ClientOnly>
                    <CommuneMap ref="mapComponent" :geojson="currentMapFeatureCollection"
                        :selected-codes="selectedCommuneCodes" :brush-mode="isBrushMode" @toggle-commune="toggleCommune"
                        @select-zone="handleSelectByZone" />
                    <template #fallback>
                        <div class="flex items-center justify-center h-full bg-gray-100 dark:bg-gray-900">
                            <div class="text-center">
                                <UIcon name="i-heroicons-map"
                                    class="text-6xl text-gray-300 dark:text-gray-700 animate-pulse mb-4" />
                                <p class="text-gray-500">Initialisation de la cartographie...</p>
                            </div>
                        </div>
                    </template>
                </ClientOnly>
            </main>
        </div>
    </div>
</template>

<script setup lang="ts">
import * as turf from '@turf/turf'
import { useGeo } from '~/composables/useGeo' // Assuming specific import otherwise auto-import

// Auto-imports should work in Nuxt, but making sure
// const { getDepartments, getCommunesByDepartment } = useGeo() // If it's a composable

// Use Nuxt auto-import for composables usually
const { getDepartments, getCommunesByDepartment } = useGeo()
const toast = useToast()

// Refs
const mapComponent = ref<any>(null)
// Expose map instance from child if possible or use event bus, but better to expose a method in child
const mapRef = computed(() => mapComponent.value)

// Data
const departments = ref<any[]>([])
const loading = ref(false)
const isBrushMode = ref(false)

// State
const loadedDeps = ref<string[]>([])
const loadedFeatures = ref<any[]>([])
const selectedCommuneCodes = ref<Set<string>>(new Set())
const selectedFeaturesMap = new Map<string, any>()

// Computed
const currentMapFeatureCollection = computed(() => {
    return {
        type: 'FeatureCollection',
        features: loadedFeatures.value
    }
})

// Lifecycle
onMounted(async () => {
    try {
        const deps = (await getDepartments()) as any[]
        departments.value = deps.map((d: any) => ({
            label: `${d.nom} (${d.code})`,
            ...d
        }))
    } catch (e) {
        toast.add({ title: 'Erreur', description: 'Impossible de charger les départements', color: 'error' })
    }

    // Key shortcut for Brush
    window.addEventListener('keydown', (e) => {
        if (e.key.toLowerCase() === 'b') {
            isBrushMode.value = !isBrushMode.value
            toast.add({
                title: isBrushMode.value ? 'Mode Pinceau' : 'Mode Navigation',
                description: isBrushMode.value ? 'Dessinez pour sélectionner' : 'Navigation libre',
                icon: isBrushMode.value ? 'i-heroicons-paint-brush' : 'i-heroicons-cursor-arrow-rays',
                duration: 2000
            })
        }
    })
})

// Actions
const loadDepartment = async (dep: any) => {
    if (!dep) return
    const code = dep.code

    if (loadedDeps.value.includes(code)) {
        toast.add({ title: 'Déjà chargé', color: 'warning' })
        return
    }

    loading.value = true
    try {
        const geojson: any = await getCommunesByDepartment(code)
        if (geojson && geojson.features) {
            loadedFeatures.value = [...loadedFeatures.value, ...geojson.features]
            loadedDeps.value.push(code)
            toast.add({ title: 'Succès', description: `${geojson.features.length} communes chargées` })
        }
    } catch (e) {
        toast.add({ title: 'Erreur', description: 'Erreur lors du chargement des communes', color: 'error' })
    } finally {
        loading.value = false
    }
}

const removeDepartment = (depCode: string) => {
    // Remove from loaded list
    loadedDeps.value = loadedDeps.value.filter(c => c !== depCode)

    // Remove features
    const featuresToRemove = loadedFeatures.value.filter(f => f.properties.codeDepartement === depCode)
    loadedFeatures.value = loadedFeatures.value.filter(f => f.properties.codeDepartement !== depCode)

    // Clean up selection for removed items
    let removedCount = 0
    featuresToRemove.forEach(f => {
        if (selectedCommuneCodes.value.has(f.properties.code)) {
            selectedCommuneCodes.value.delete(f.properties.code)
            selectedFeaturesMap.delete(f.properties.code)
            removedCount++
        }
    })

    // Update Set reactivity
    selectedCommuneCodes.value = new Set(selectedCommuneCodes.value)

    toast.add({ title: 'Suppression', description: `Département retiré (${removedCount} sélections annulées)` })
}

const toggleCommune = (feature: any, forceSelect?: boolean) => {
    const code = feature.properties.code

    if (forceSelect) {
        if (!selectedCommuneCodes.value.has(code)) {
            selectedCommuneCodes.value.add(code)
            selectedFeaturesMap.set(code, feature)
            selectedCommuneCodes.value = new Set(selectedCommuneCodes.value)
        }
        return
    }

    if (selectedCommuneCodes.value.has(code)) {
        selectedCommuneCodes.value.delete(code)
        selectedFeaturesMap.delete(code)
    } else {
        selectedCommuneCodes.value.add(code)
        selectedFeaturesMap.set(code, feature)
    }
    selectedCommuneCodes.value = new Set(selectedCommuneCodes.value)
}

const selectAllInDep = (depCode: string) => {
    const featuresInDep = loadedFeatures.value.filter(f => f.properties.codeDepartement === depCode)
    let addedCount = 0
    featuresInDep.forEach(f => {
        if (!selectedCommuneCodes.value.has(f.properties.code)) {
            selectedCommuneCodes.value.add(f.properties.code)
            selectedFeaturesMap.set(f.properties.code, f)
            addedCount++
        }
    })
    selectedCommuneCodes.value = new Set(selectedCommuneCodes.value)
    toast.add({ title: 'Sélection', description: `${addedCount} communes ajoutées` })
}

const selectAll = () => {
    let addedCount = 0
    loadedFeatures.value.forEach(f => {
        if (!selectedCommuneCodes.value.has(f.properties.code)) {
            selectedCommuneCodes.value.add(f.properties.code)
            selectedFeaturesMap.set(f.properties.code, f)
            addedCount++
        }
    })
    selectedCommuneCodes.value = new Set(selectedCommuneCodes.value)
    toast.add({ title: 'Sélection', description: `${addedCount} communes ajoutées` })
}

const handleSelectByZone = (zone: any) => {
    let searchPolygon: any
    try {
        if (zone.type === 'circle') {
            searchPolygon = turf.circle(zone.center, zone.radius, { units: 'meters' })
        } else {
            searchPolygon = zone.geometry
        }

        let addedCount = 0
        loadedFeatures.value.forEach((feature: any) => {
            if (selectedCommuneCodes.value.has(feature.properties.code)) return
            // Simple bbox check first for perf? default intersect is okay for normal amounts
            if (turf.booleanIntersects(searchPolygon, feature)) {
                selectedCommuneCodes.value.add(feature.properties.code)
                selectedFeaturesMap.set(feature.properties.code, feature)
                addedCount++
            }
        })

        if (addedCount > 0) {
            selectedCommuneCodes.value = new Set(selectedCommuneCodes.value)
            toast.add({ title: 'Sélection', description: `${addedCount} communes ajoutées`, color: 'success' })
        }
    } catch (e) {
        console.warn(e)
    }
}

const clearMap = () => {
    loadedFeatures.value = []
    loadedDeps.value = []
    clearSelection()
}

const clearSelection = () => {
    selectedCommuneCodes.value = new Set()
    selectedFeaturesMap.clear()
}

const downloadGeoJson = () => {
    if (selectedFeaturesMap.size === 0) return

    // Deep clone to remove Vue Reactivity/Proxies
    const features = Array.from(selectedFeaturesMap.values()).map(f => JSON.parse(JSON.stringify(f)))

    try {
        if (features.length === 0) return

        let merged: any

        if (features.length === 1) {
            merged = features[0]
        } else {
            // Turf v7 prefers handling a FeatureCollection for union
            // This also handles multiple polygons much more efficiently than iterative union
            const fc = turf.featureCollection(features)
            // Cast to any because turf generic types can be finicky with inferred unions
            merged = turf.union(fc as any)
        }

        if (!merged) {
            throw new Error('La fusion a retourné un résultat vide')
        }

        const result = { type: 'FeatureCollection', features: [merged] }
        const blob = new Blob([JSON.stringify(result)], { type: 'application/json' })
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = 'zone-communes.geojson'
        a.click()
        URL.revokeObjectURL(url)
        toast.add({ title: 'Export', description: 'Fichier GeoJSON généré avec succès' })
    } catch (e: any) {
        console.error('Merge error:', e)
        toast.add({ title: 'Erreur', description: 'Erreur lors de la fusion: ' + (e.message || 'Inconnue'), color: 'error' })
    }
}

const flyToCommune = (feature: any) => {
    if (mapComponent.value) {
        mapComponent.value.flyToFeature(feature)
    }
}
</script>
