<script setup lang="ts">
import { BarChart3, CircleHelp, Menu, X } from '@lucide/vue'
import { ref, watch } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'

const menuOpen = ref(false)
const route = useRoute()
const contactEmail = import.meta.env.VITE_CONTACT_EMAIL

watch(() => route.fullPath, () => {
  menuOpen.value = false
})
</script>

<template>
  <div class="site-shell">
    <header class="site-header">
      <div class="nav-wrap">
        <RouterLink class="wordmark" to="/" aria-label="Verdict home">
          <span class="wordmark-mark">V</span>
          <span>VERDICT</span>
        </RouterLink>

        <button
          class="icon-button mobile-menu-button"
          type="button"
          :aria-label="menuOpen ? 'Close menu' : 'Open menu'"
          :aria-expanded="menuOpen"
          @click="menuOpen = !menuOpen"
        >
          <X v-if="menuOpen" :size="22" stroke-width="3" />
          <Menu v-else :size="22" stroke-width="3" />
        </button>

        <nav class="main-nav" :class="{ 'main-nav--open': menuOpen }" aria-label="Main navigation">
          <RouterLink to="/how-to-play"><CircleHelp :size="18" /> How to play</RouterLink>
          <RouterLink to="/stats"><BarChart3 :size="18" /> Stats</RouterLink>
          <RouterLink class="button button--small button--ink" to="/play">Play today</RouterLink>
        </nav>
      </div>
    </header>

    <main>
      <RouterView />
    </main>

    <footer class="site-footer">
      <div class="footer-grid">
        <div>
          <RouterLink class="wordmark wordmark--footer" to="/">
            <span class="wordmark-mark">V</span>
            <span>VERDICT</span>
          </RouterLink>
          <p>Six guesses. One verdict.<br />A fresh word lands every day at midnight UTC.</p>
        </div>
        <div class="footer-links">
          <strong>PLAY</strong>
          <RouterLink to="/play">Daily puzzle</RouterLink>
          <RouterLink to="/stats">Your stats</RouterLink>
          <RouterLink to="/how-to-play">How it works</RouterLink>
        </div>
        <div class="footer-links">
          <strong>LEGAL</strong>
          <RouterLink to="/privacy">Privacy</RouterLink>
          <RouterLink to="/terms">Terms</RouterLink>
          <a v-if="contactEmail" :href="`mailto:${contactEmail}`">Contact</a>
        </div>
      </div>
      <div class="footer-bottom">
        <span>© {{ new Date().getFullYear() }} Verdict</span>
        <span>Made for word people.</span>
      </div>
    </footer>
  </div>
</template>
