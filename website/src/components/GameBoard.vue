<script setup lang="ts">
import { computed, type CSSProperties } from 'vue'

import type { Grade } from '@/lib/game'

const props = defineProps<{
  guesses: string[]
  evaluations: Grade[][]
  currentGuess: string
  revealingRow: number | null
  shakeCount: number
}>()

const rows = computed(() => Array.from({ length: 6 }, (_, rowIndex) => {
  const guess = props.guesses[rowIndex]
  const word = guess ?? (rowIndex === props.guesses.length ? props.currentGuess : '')
  return Array.from({ length: 5 }, (_, columnIndex) => ({
    letter: word[columnIndex] ?? '',
    grade: props.evaluations[rowIndex]?.[columnIndex],
    rowIndex,
    columnIndex,
  }))
}))

const tileStyle = (columnIndex: number): CSSProperties => ({
  '--reveal-delay': `${columnIndex * 150}ms`,
})
</script>

<template>
  <div class="game-board" aria-label="Guess board" aria-live="polite">
    <div
      v-for="(row, rowIndex) in rows"
      :key="`${rowIndex}-${rowIndex === guesses.length ? shakeCount : 0}`"
      class="game-row"
      :class="{
        'game-row--shake': rowIndex === guesses.length && shakeCount > 0,
        'game-row--revealing': rowIndex === revealingRow,
      }"
      :data-shake="rowIndex === guesses.length ? shakeCount : undefined"
    >
      <div
        v-for="tile in row"
        :key="tile.columnIndex"
        class="game-tile"
        :class="[
          tile.grade ? `game-tile--${tile.grade}` : '',
          tile.letter ? 'game-tile--filled' : '',
        ]"
        :style="tileStyle(tile.columnIndex)"
        :aria-label="tile.grade ? `${tile.letter}, ${tile.grade}` : tile.letter || 'empty'"
      >
        <span>{{ tile.letter }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.game-board {
  display: grid;
  width: min(100%, 350px);
  gap: 7px;
  margin: 0 auto 26px;
}

.game-row {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 7px;
}

.game-tile {
  display: grid;
  aspect-ratio: 1;
  place-items: center;
  border: 3px solid var(--ink);
  background: var(--white);
  box-shadow: 3px 3px 0 var(--ink);
  font-size: clamp(1.45rem, 6vw, 2.15rem);
  font-weight: 700;
  line-height: 1;
  text-transform: uppercase;
  transform-style: preserve-3d;
}

.game-tile--filled:not(.game-tile--hit):not(.game-tile--near):not(.game-tile--miss) {
  animation: tile-pop 110ms ease-out;
}

.game-tile--hit {
  background: var(--green);
  color: var(--ink);
}

.game-tile--near {
  background: var(--yellow);
  color: var(--ink);
}

.game-tile--miss {
  background: var(--miss);
  color: var(--white);
}

.game-row--revealing .game-tile {
  animation: tile-reveal 560ms var(--reveal-delay) ease both;
}

.game-row--shake {
  animation: row-shake 340ms ease;
}

@keyframes tile-pop {
  50% { transform: scale(1.08); }
}

@keyframes tile-reveal {
  0% { transform: rotateX(0); }
  48% { transform: rotateX(90deg); }
  52% { transform: rotateX(90deg); }
  100% { transform: rotateX(0); }
}

@keyframes row-shake {
  0%, 100% { transform: translateX(0); }
  20%, 60% { transform: translateX(-6px); }
  40%, 80% { transform: translateX(6px); }
}

@media (max-width: 420px) {
  .game-board,
  .game-row {
    gap: 5px;
  }

  .game-tile {
    border-width: 2.5px;
    box-shadow: 2px 2px 0 var(--ink);
  }
}
</style>
