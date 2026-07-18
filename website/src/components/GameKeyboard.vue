<script setup lang="ts">
import { Delete } from '@lucide/vue'

import type { Grade } from '@/lib/game'

defineProps<{
  grades: Record<string, Grade>
  disabled?: boolean
}>()

const emit = defineEmits<{
  letter: [letter: string]
  enter: []
  delete: []
}>()

const rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm']
</script>

<template>
  <div class="keyboard" aria-label="On-screen keyboard">
    <div v-for="(row, rowIndex) in rows" :key="row" class="keyboard-row">
      <button
        v-if="rowIndex === 2"
        class="key key--wide"
        type="button"
        :disabled="disabled"
        aria-label="Submit guess"
        @click="emit('enter')"
      >
        Enter
      </button>
      <button
        v-for="letter in row"
        :key="letter"
        class="key"
        :class="grades[letter] ? `key--${grades[letter]}` : ''"
        type="button"
        :disabled="disabled"
        :aria-label="`${letter}${grades[letter] ? `, ${grades[letter]}` : ''}`"
        @click="emit('letter', letter)"
      >
        {{ letter }}
      </button>
      <button
        v-if="rowIndex === 2"
        class="key key--wide"
        type="button"
        :disabled="disabled"
        aria-label="Delete letter"
        @click="emit('delete')"
      >
        <Delete :size="21" :stroke-width="3" />
      </button>
    </div>
  </div>
</template>

<style scoped>
.keyboard {
  display: grid;
  gap: 7px;
  width: 100%;
  max-width: 530px;
  margin: 0 auto;
}

.keyboard-row {
  display: flex;
  justify-content: center;
  gap: 5px;
}

.key {
  min-width: 0;
  height: 48px;
  flex: 1;
  padding: 0 3px;
  border: 2px solid var(--ink);
  border-radius: 2px;
  background: #ded9d0;
  box-shadow: 2px 2px 0 var(--ink);
  cursor: pointer;
  font-size: 0.88rem;
  font-weight: 700;
  text-transform: uppercase;
  transition: transform 90ms ease, box-shadow 90ms ease;
}

.key:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 2px 3px 0 var(--ink);
}

.key:active:not(:disabled) {
  transform: translate(2px, 2px);
  box-shadow: none;
}

.key:focus-visible {
  position: relative;
  z-index: 2;
  outline: 3px solid var(--blue);
  outline-offset: 2px;
}

.key:disabled {
  cursor: default;
}

.key--wide {
  flex: 1.55;
  font-size: 0.67rem;
}

.key--wide svg {
  margin: auto;
}

.key--hit {
  background: var(--green);
}

.key--near {
  background: var(--yellow);
}

.key--miss {
  background: var(--miss);
  color: var(--white);
}

@media (max-width: 420px) {
  .keyboard,
  .keyboard-row {
    gap: 4px;
  }

  .key {
    height: 46px;
    padding: 0 1px;
    box-shadow: 1.5px 1.5px 0 var(--ink);
    font-size: 0.78rem;
  }

  .key--wide {
    font-size: 0.58rem;
  }
}
</style>
