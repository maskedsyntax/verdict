<script setup lang="ts">
import { Share2, X } from '@lucide/vue'

import AdSlot from '@/components/AdSlot.vue'
import { useCountdown } from '@/composables/useCountdown'
import type { GameStatus } from '@/lib/game'
import { loadStats } from '@/lib/storage'

defineProps<{
  status: Exclude<GameStatus, 'playing'>
  answer: string
  guessCount: number
  puzzleNumber: number
  shareLabel: string
}>()

const emit = defineEmits<{
  close: []
  share: []
}>()

const countdown = useCountdown()
const stats = loadStats()
const winRate = stats.gamesPlayed ? Math.round((stats.wins / stats.gamesPlayed) * 100) : 0
const resultAdSlot = import.meta.env.VITE_ADSENSE_RESULTS_SLOT
</script>

<template>
  <div class="result-backdrop" role="presentation" @click.self="emit('close')">
    <section class="result-panel" role="dialog" aria-modal="true" aria-labelledby="result-heading">
      <button class="result-close icon-button" type="button" aria-label="Close results" @click="emit('close')">
        <X :size="21" :stroke-width="3" />
      </button>

      <div class="result-stamp" :class="status === 'won' ? 'result-stamp--won' : 'result-stamp--lost'">
        {{ status === 'won' ? 'CASE CLOSED' : 'CASE COLD' }}
      </div>
      <p class="result-kicker">Verdict #{{ puzzleNumber }}</p>
      <h2 id="result-heading">{{ status === 'won' ? 'A decisive ruling.' : 'The word got away.' }}</h2>
      <p class="result-copy">
        {{ status === 'won' ? `You found it in ${guessCount} ${guessCount === 1 ? 'guess' : 'guesses'}.` : 'Today’s answer was:' }}
      </p>
      <div class="answer-box">{{ answer }}</div>

      <div class="result-stats" aria-label="Your statistics">
        <div><strong>{{ stats.gamesPlayed }}</strong><span>Played</span></div>
        <div><strong>{{ winRate }}</strong><span>Win %</span></div>
        <div><strong>{{ stats.currentStreak }}</strong><span>Streak</span></div>
        <div><strong>{{ stats.maxStreak }}</strong><span>Best</span></div>
      </div>

      <div class="next-verdict">
        <span>Next verdict</span>
        <strong>{{ countdown }}</strong>
      </div>

      <button class="button button--green result-share" type="button" @click="emit('share')">
        <Share2 :size="20" :stroke-width="3" />
        {{ shareLabel }}
      </button>

      <AdSlot :slot="resultAdSlot" placement="results" />
    </section>
  </div>
</template>

<style scoped>
.result-backdrop {
  position: fixed;
  z-index: 100;
  inset: 0;
  display: grid;
  overflow-y: auto;
  place-items: center;
  padding: 24px;
  background: rgb(23 23 23 / 72%);
  backdrop-filter: blur(3px);
}

.result-panel {
  position: relative;
  width: min(100%, 540px);
  margin: auto;
  padding: 44px;
  border: 4px solid var(--ink);
  background: var(--paper);
  box-shadow: 10px 10px 0 var(--yellow);
  text-align: center;
  animation: result-in 260ms cubic-bezier(.2, .85, .35, 1.2);
}

.result-close {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 38px;
  height: 38px;
  background: var(--white);
}

.result-stamp {
  display: inline-block;
  margin-bottom: 20px;
  padding: 8px 13px;
  border: var(--border);
  box-shadow: 3px 3px 0 var(--ink);
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 0.13em;
  transform: rotate(-2deg);
}

.result-stamp--won {
  background: var(--green);
}

.result-stamp--lost {
  background: var(--coral);
}

.result-kicker {
  margin-bottom: 10px;
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.result-panel h2 {
  margin-bottom: 14px;
  font-size: clamp(2rem, 7vw, 3.2rem);
}

.result-copy {
  margin-bottom: 14px;
}

.answer-box {
  margin: 0 auto 28px;
  padding: 10px 20px;
  border: var(--border);
  background: var(--yellow);
  font-size: 1.5rem;
  font-weight: 700;
  letter-spacing: 0.2em;
  text-transform: uppercase;
}

.result-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  margin-bottom: 24px;
  border: var(--border);
  background: var(--white);
}

.result-stats > div {
  display: flex;
  flex-direction: column;
  padding: 13px 4px;
}

.result-stats > div + div {
  border-left: 2px solid var(--ink);
}

.result-stats strong {
  font-size: 1.65rem;
  line-height: 1;
}

.result-stats span {
  margin-top: 5px;
  font-size: 0.68rem;
  font-weight: 650;
  text-transform: uppercase;
}

.next-verdict {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
  font-size: 0.82rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.next-verdict strong {
  font-variant-numeric: tabular-nums;
}

.result-share {
  width: 100%;
}

@keyframes result-in {
  from { opacity: 0; transform: translateY(24px) rotate(1deg); }
  to { opacity: 1; transform: translateY(0) rotate(0); }
}

@media (max-width: 560px) {
  .result-backdrop {
    align-items: end;
    padding: 0;
  }

  .result-panel {
    width: 100%;
    padding: 34px 20px 28px;
    border-width: 3px 0 0;
    box-shadow: none;
  }
}
</style>
