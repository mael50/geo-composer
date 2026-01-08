<template>
    <div ref="mapContainer" class="h-full w-full rounded-lg shadow-md"></div>
</template>

<script setup lang="ts">
import L from 'leaflet'

const props = defineProps<{
    geojson: any
    selectedCodes: Set<string>
    brushMode?: boolean
}>()

const emit = defineEmits(['toggle-commune', 'select-zone'])

const mapContainer = ref<HTMLElement | null>(null)
let map: L.Map | null = null
let geoJsonLayer: L.GeoJSON | null = null
let isMouseDown = false

onMounted(async () => {
    // Wait for next tick to ensure container has dimensions
    await nextTick()

    // Additional small delay for layout stability
    setTimeout(() => {
        if (mapContainer.value) {
            map = L.map(mapContainer.value, {
                zoomControl: false,
                preferCanvas: true // Performance boost
            }).setView([46.603354, 1.888334], 6)

            L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
                subdomains: 'abcd',
                maxZoom: 20
            }).addTo(map)

            map.on('mousedown', () => { isMouseDown = true })
            map.on('mouseup', () => { isMouseDown = false })
            map.on('mouseout', () => { isMouseDown = false })

            updateLayer()

            // Force resize calculation
            map.invalidateSize()
        }
    }, 100)
})

onUnmounted(() => {
    if (map) {
        map.remove()
        map = null
    }
})

watch(() => props.brushMode, (val) => {
    if (map) {
        if (val) {
            map.dragging.disable()
            map.getContainer().style.cursor = 'crosshair'
        } else {
            map.dragging.enable()
            map.getContainer().style.cursor = ''
        }
    }
})

watch(() => props.geojson, () => {
    updateLayer()
}, { deep: true })

watch(() => props.selectedCodes, () => {
    if (geoJsonLayer) {
        geoJsonLayer.setStyle(getStyle)
    }
}, { deep: true })

const getStyle = (feature: any) => {
    const isSelected = props.selectedCodes.has(feature.properties.code)
    return {
        color: isSelected ? '#10b981' : '#3b82f6',
        weight: 1,
        fillOpacity: isSelected ? 0.6 : 0.1,
        fillColor: isSelected ? '#10b981' : '#3b82f6'
    }
}

const updateLayer = () => {
    if (!map) return
    if (geoJsonLayer) {
        map.removeLayer(geoJsonLayer)
    }

    if (!props.geojson || !props.geojson.features || props.geojson.features.length === 0) return

    geoJsonLayer = L.geoJSON(props.geojson, {
        style: getStyle,
        onEachFeature: (feature, layer) => {
            // Click handler (standard)
            layer.on('click', () => {
                // If brush mode, click also acts as paint start
                if (props.brushMode) {
                    emit('toggle-commune', feature, true) // Force select
                } else {
                    emit('toggle-commune', feature)
                }
            })

            // Brush handler
            layer.on('mouseover', () => {
                if (props.brushMode && isMouseDown) {
                    emit('toggle-commune', feature, true) // Force select on drag
                }
            })
            // Mouse down on feature starts painting immediately
            layer.on('mousedown', () => {
                if (props.brushMode) {
                    emit('toggle-commune', feature, true)
                }
            })
            // Tooltip with name
            layer.bindTooltip(`${feature.properties.nom} (${feature.properties.code})`)
        }
    }).addTo(map)

    // Fit bounds if it's the first load or if requested (optional)
    if (props.geojson.features.length > 0) {
        const bounds = geoJsonLayer.getBounds()
        if (bounds.isValid()) {
            map.fitBounds(bounds)
        }
    }
}

// Expose methods for parent
const zoomIn = () => map?.zoomIn()
const zoomOut = () => map?.zoomOut()
const flyToFeature = (feature: any) => {
    if (!map) return
    // Calculate bounds
    const layer = L.geoJSON(feature)
    const bounds = layer.getBounds()
    if (bounds.isValid()) {
        map.fitBounds(bounds, { maxZoom: 12, animate: true })
    }
}

defineExpose({
    zoomIn,
    zoomOut,
    flyToFeature
})
</script>

<style>
/* Fix Leaflet icon issue if default markers are used (though we use geojson) */
</style>
