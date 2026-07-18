<script setup lang="ts">
import { ArrowRight, Flame, Trophy } from '@lucide/vue'
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'

import AdSlot from '@/components/AdSlot.vue'
import { loadStats, type PlayerStats } from '@/lib/storage'

const stats = ref<PlayerStats>(loadStats())
const winRate = computed(() => stats.value.gamesPlayed ? Math.round((stats.value.wins / stats.value.gamesPlayed) * 100) : 0)
const distributionMax = computed(() => Math.max(1, ...stats.value.distribution))
const statsAdSlot = import.meta.env.VITE_ADSENSE_STATS_SLOT

const refresh = () => {
  stats.value = loadStats()
}

onMounted(() => window.addEventListener('verdict:stats-updated', refresh))
onBeforeUnmount(() => window.removeEventListener('verdict:stats-updated', refresh))
</script>

<template>
  <div class="content-page stats-page">
    <div class="page-wrap">
      <div class="page-intro stats-intro">
        <div>
          <span class="eyebrow">Your record</span>
          <h1>THE NUMBERS<br />DON’T LIE.</h1>
          <p>Your statistics live in this browser. No account, profile, or personal details required.</p>
        </div>
        <div class="record-stamp"><Trophy :size="28" /> Personal docket</div>
      </div>

      <section class="stat-grid" aria-label="Game statistics">
        <article><strong>{{ stats.gamesPlayed }}</strong><span>Played</span></article>
        <article><strong>{{ winRate }}<small>%</small></strong><span>Win rate</span></article>
        <article class="stat-streak"><strong>{{ stats.currentStreak }}</strong><span>Current streak</span><Flame :size="34" fill="currentColor" /></article>
        <article><strong>{{ stats.maxStreak }}</strong><span>Best streak</span></article>
      </section>

      <div class="stats-lower">
        <section class="distribution surface">
          <div class="panel-heading">
            <div><span>Performance</span><h2>Guess distribution</h2></div>
            <span>{{ stats.wins }} {{ stats.wins === 1 ? 'win' : 'wins' }}</span>
          </div>
          <div class="distribution-bars">
            <div v-for="(count, index) in stats.distribution" :key="index" class="distribution-row">
              <strong>{{ index + 1 }}</strong>
              <div class="bar-track">
                <div class="bar-fill" :style="{ width: `${Math.max(count ? 12 : 4, (count / distributionMax) * 100)}%` }">
                  <span>{{ count }}</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        <aside class="streak-card">
          <span class="eyebrow">Keep it alive</span>
          <Flame :size="54" fill="currentColor" />
          <h2>{{ stats.currentStreak ? `${stats.currentStreak}-day run.` : 'Start the run.' }}</h2>
          <p>{{ stats.currentStreak ? 'Return tomorrow to extend your current streak.' : 'Solve today’s word to put your first win on the board.' }}</p>
          <RouterLink class="button button--ink" to="/play">Play today <ArrowRight :size="20" /></RouterLink>
        </aside>
      </div>

      <AdSlot :slot="statsAdSlot" placement="stats" />
    </div>
  </div>
</template>

<style scoped>
.stats-page { min-height: 820px; }
.stats-intro { display: flex; max-width: none; align-items: center; justify-content: space-between; gap: 40px; }
.stats-intro h1 { margin-bottom: 20px; }
.record-stamp { display: flex; flex: none; align-items: center; gap: 10px; padding: 17px 20px; border: var(--border); background: var(--yellow); box-shadow: var(--shadow); font-weight: 700; text-transform: uppercase; transform: rotate(3deg); }
.stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); margin-bottom: 38px; border: var(--border); background: var(--white); box-shadow: var(--shadow); }
.stat-grid article { position: relative; display: flex; min-height: 165px; flex-direction: column; justify-content: center; padding: 25px; overflow: hidden; }
.stat-grid article + article { border-left: var(--border); }
.stat-grid strong { font-size: clamp(2.7rem, 6vw, 4.5rem); letter-spacing: -0.06em; line-height: .9; }
.stat-grid small { font-size: .45em; }
.stat-grid span { margin-top: 14px; font-size: .75rem; font-weight: 700; letter-spacing: .1em; text-transform: uppercase; }
.stat-streak { background: var(--coral); }
.stat-streak svg { position: absolute; top: 18px; right: 18px; }
.stats-lower { display: grid; grid-template-columns: 1.4fr .6fr; gap: 34px; }
.distribution { padding: clamp(24px, 5vw, 42px); }
.panel-heading { display: flex; align-items: flex-end; justify-content: space-between; gap: 20px; margin-bottom: 34px; padding-bottom: 22px; border-bottom: 2px solid var(--ink); }
.panel-heading > div > span, .panel-heading > span { font-size: .72rem; font-weight: 700; letter-spacing: .1em; text-transform: uppercase; }
.panel-heading h2 { margin: 7px 0 0; font-size: clamp(1.7rem, 4vw, 2.6rem); }
.distribution-bars { display: grid; gap: 10px; }
.distribution-row { display: grid; grid-template-columns: 22px 1fr; align-items: center; gap: 12px; }
.distribution-row > strong { font-size: .85rem; text-align: center; }
.bar-track { height: 34px; border: 2px solid var(--ink); background: var(--paper-deep); }
.bar-fill { display: flex; min-width: 28px; height: 100%; align-items: center; justify-content: flex-end; background: var(--green); transition: width 450ms ease; }
.bar-fill span { padding: 0 8px; font-size: .75rem; font-weight: 700; }
.streak-card { padding: 36px; border: var(--border); background: var(--yellow); box-shadow: var(--shadow); }
.streak-card > svg { margin: 12px 0 24px; color: var(--coral); }
.streak-card h2 { margin-bottom: 17px; font-size: 2.4rem; }
.streak-card p { margin-bottom: 28px; }

@media (max-width: 850px) {
  .stat-grid { grid-template-columns: repeat(2, 1fr); }
  .stat-grid article:nth-child(3) { border-left: 0; border-top: var(--border); }
  .stat-grid article:nth-child(4) { border-top: var(--border); }
  .stats-lower { grid-template-columns: 1fr; }
}

@media (max-width: 580px) {
  .stats-intro { align-items: flex-start; flex-direction: column; }
  .record-stamp { align-self: flex-end; }
  .stat-grid article { min-height: 130px; padding: 18px; }
  .panel-heading { align-items: flex-start; flex-direction: column; }
}
</style>
