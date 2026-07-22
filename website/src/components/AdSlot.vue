<script setup lang="ts">
import { nextTick, onMounted } from 'vue'

import { loadAdsense } from '@/lib/adsense'

const props = defineProps<{
  slot?: string
  placement: 'results' | 'stats' | 'home' | 'howto'
}>()

const client = import.meta.env.VITE_ADSENSE_CLIENT
const configured = Boolean(client && props.slot)
const showPlaceholder = import.meta.env.DEV

onMounted(async () => {
  if (!configured) return
  try {
    await loadAdsense()
    await nextTick()
    window.adsbygoogle = window.adsbygoogle ?? []
    window.adsbygoogle.push({})
  } catch {
    // Ad blockers and network failures must never interrupt the game.
  }
})
</script>

<template>
  <aside v-if="configured || showPlaceholder" class="ad-wrap" :data-placement="placement" aria-label="Advertisement">
    <span class="ad-label">Advertisement</span>
    <ins
      v-if="configured"
      class="adsbygoogle"
      style="display: block"
      :data-ad-client="client"
      :data-ad-slot="slot"
      data-ad-format="auto"
      data-full-width-responsive="true"
    />
    <div v-else class="ad-placeholder">
      <strong>AD SPACE</strong>
      <span>{{ placement }} · responsive</span>
    </div>
  </aside>
</template>

<style scoped>
.ad-wrap {
  width: 100%;
  margin: 24px auto 0;
  text-align: center;
}

.ad-label {
  display: block;
  margin-bottom: 7px;
  color: #77746f;
  font-size: 0.66rem;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.ad-placeholder {
  display: flex;
  min-height: 92px;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border: 2px dashed #a7a199;
  background: #eee8de;
  color: #77746f;
}

.ad-placeholder strong {
  font-size: 0.76rem;
  letter-spacing: 0.12em;
}

.ad-placeholder span {
  font-size: 0.72rem;
}
</style>
