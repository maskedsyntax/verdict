<script setup lang="ts">
import { ArrowRight, CalendarDays, Keyboard, Share2 } from '@lucide/vue'
import { RouterLink } from 'vue-router'

const examples = [
  { word: 'SLATE', highlight: 0, grade: 'hit', title: 'S is in the right spot', copy: 'A green tile is final. Keep that letter exactly where it is.' },
  { word: 'BRICK', highlight: 1, grade: 'near', title: 'R is in the word', copy: 'A yellow tile belongs in the answer, but not in that position.' },
  { word: 'POUND', highlight: 2, grade: 'miss', title: 'U is not in the word', copy: 'A gray tile is absent from the answer. Try something new.' },
]
</script>

<template>
  <div class="content-page how-page">
    <div class="page-wrap">
      <div class="page-intro">
        <span class="eyebrow">Rules of the case</span>
        <h1>HOW TO<br />DELIVER A VERDICT.</h1>
        <p>Find the five-letter word in six valid guesses. Every submitted row returns evidence you can use in the next one.</p>
      </div>

      <section class="rules-grid">
        <article v-for="example in examples" :key="example.word" class="rule-card">
          <div class="example-row">
            <div
              v-for="(letter, index) in example.word"
              :key="index"
              class="example-tile"
              :class="index === example.highlight ? `example-tile--${example.grade}` : ''"
            >{{ letter }}</div>
          </div>
          <span class="rule-grade">{{ example.grade }}</span>
          <h2>{{ example.title }}</h2>
          <p>{{ example.copy }}</p>
        </article>
      </section>

      <section class="play-steps surface">
        <div class="play-steps-heading">
          <span class="eyebrow">The short version</span>
          <h2>Open. Guess. Judge. Repeat.</h2>
        </div>
        <div class="steps-list">
          <div><span>01</span><Keyboard :size="26" /><p>Type any valid five-letter word using your keyboard or the keys on screen.</p></div>
          <div><span>02</span><CalendarDays :size="26" /><p>Use the color evidence to solve the same daily word as every other player.</p></div>
          <div><span>03</span><Share2 :size="26" /><p>Share your colored result grid without revealing any of the letters.</p></div>
        </div>
      </section>

      <section class="rules-cta">
        <h2>Ready to rule?</h2>
        <p>Today’s case is open now.</p>
        <RouterLink class="button button--ink" to="/play">Play Verdict <ArrowRight :size="20" /></RouterLink>
      </section>
    </div>
  </div>
</template>

<style scoped>
.rules-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 80px; }
.rule-card { padding: 26px; border: var(--border); background: var(--white); box-shadow: var(--shadow); }
.example-row { display: grid; grid-template-columns: repeat(5, 1fr); gap: 5px; margin-bottom: 30px; }
.example-tile { display: grid; aspect-ratio: 1; place-items: center; border: 2px solid var(--ink); background: var(--paper); font-size: 1.25rem; font-weight: 700; }
.example-tile--hit { background: var(--green); }
.example-tile--near { background: var(--yellow); }
.example-tile--miss { background: var(--miss); color: var(--white); }
.rule-grade { font-size: .7rem; font-weight: 700; letter-spacing: .13em; text-transform: uppercase; }
.rule-card h2 { margin: 11px 0 16px; font-size: 1.7rem; }
.rule-card p { margin: 0; }
.play-steps { display: grid; grid-template-columns: .8fr 1.2fr; gap: 60px; margin-bottom: 80px; padding: clamp(28px, 6vw, 58px); }
.play-steps-heading h2 { margin: 0; font-size: clamp(2.2rem, 5vw, 4rem); }
.steps-list { display: grid; }
.steps-list > div { display: grid; grid-template-columns: 30px 32px 1fr; gap: 15px; padding: 24px 0; border-bottom: 2px solid var(--ink); }
.steps-list > div:first-child { padding-top: 0; }
.steps-list > div:last-child { padding-bottom: 0; border-bottom: 0; }
.steps-list span { font-size: .72rem; font-weight: 700; }
.steps-list p { margin: 0; line-height: 1.5; }
.rules-cta { padding: 70px; border: var(--border); background: var(--green); box-shadow: var(--shadow); text-align: center; }
.rules-cta h2 { margin-bottom: 12px; }
.rules-cta p { margin-bottom: 26px; }
.rules-cta .button { width: auto; }

@media (max-width: 900px) {
  .rules-grid { grid-template-columns: 1fr; }
  .rule-card { display: grid; grid-template-columns: minmax(230px, .8fr) 1.2fr; column-gap: 28px; align-items: center; }
  .rule-card .example-row { grid-row: 1 / 4; margin: 0; }
  .rule-card h2, .rule-card p { grid-column: 2; }
  .rule-grade { grid-column: 2; }
  .play-steps { grid-template-columns: 1fr; }
}

@media (max-width: 600px) {
  .rule-card { display: block; }
  .rule-card .example-row { margin-bottom: 28px; }
  .rules-cta { padding: 50px 22px; }
}
</style>
