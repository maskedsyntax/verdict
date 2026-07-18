<script setup lang="ts">
import { ArrowRight, BellRing, Clock3, Flame, Layers3, LockKeyhole, Share2, Sparkles } from '@lucide/vue'
import { RouterLink } from 'vue-router'

const previewRows = [
  [
    { letter: 'C', grade: 'miss' }, { letter: 'R', grade: 'near' }, { letter: 'A', grade: 'miss' }, { letter: 'N', grade: 'miss' }, { letter: 'E', grade: 'hit' },
  ],
  [
    { letter: 'S', grade: 'hit' }, { letter: 'T', grade: 'near' }, { letter: 'O', grade: 'miss' }, { letter: 'R', grade: 'near' }, { letter: 'E', grade: 'hit' },
  ],
  [
    { letter: 'S', grade: 'hit' }, { letter: 'H', grade: 'hit' }, { letter: 'I', grade: 'hit' }, { letter: 'R', grade: 'hit' }, { letter: 'E', grade: 'hit' },
  ],
]

const modes = [
  { name: 'Blitz', code: '01', copy: 'Sixty seconds. Zero room for second thoughts.', color: 'yellow', icon: Clock3 },
  { name: 'Vault', code: '02', copy: 'Four guesses, with every missed key locked out.', color: 'coral', icon: LockKeyhole },
  { name: 'Twin', code: '03', copy: 'One guess goes on trial against two words.', color: 'blue', icon: Layers3 },
  { name: 'Shift', code: '04', copy: 'The word changes length. Your method changes too.', color: 'purple', icon: Sparkles },
]
</script>

<template>
  <div>
    <section class="hero">
      <div class="hero-shape hero-shape--one" />
      <div class="hero-shape hero-shape--two" />
      <div class="page-wrap hero-grid">
        <div class="hero-copy">
          <div class="eyebrow"><span class="live-dot" /> New word every day</div>
          <h1>THE DAILY WORD IS <span>WAITING.</span></h1>
          <p>
            Read the clues. Trust your hunch. Deliver the final word in six tries or fewer.
            No account, no noise, just one sharp daily puzzle.
          </p>
          <div class="hero-actions">
            <RouterLink class="button button--ink" to="/play">
              Play today’s Verdict <ArrowRight :size="21" :stroke-width="3" />
            </RouterLink>
            <RouterLink class="text-link" to="/how-to-play">See how it works</RouterLink>
          </div>
          <div class="hero-proof">
            <div><strong>6</strong><span>guesses</span></div>
            <div><strong>1</strong><span>daily word</span></div>
            <div><strong>0</strong><span>sign-ups</span></div>
          </div>
        </div>

        <div class="hero-visual" aria-label="Example Verdict puzzle">
          <div class="case-label">CASE #001</div>
          <div class="preview-card">
            <div class="preview-card-top">
              <span>VERDICT</span>
              <span>3/6</span>
            </div>
            <div class="preview-board">
              <div v-for="(row, rowIndex) in previewRows" :key="rowIndex" class="preview-row">
                <div
                  v-for="tile in row"
                  :key="tile.letter"
                  class="preview-tile"
                  :class="`preview-tile--${tile.grade}`"
                >
                  {{ tile.letter }}
                </div>
              </div>
              <div v-for="row in 3" :key="`empty-${row}`" class="preview-row">
                <div v-for="tile in 5" :key="tile" class="preview-tile preview-tile--empty" />
              </div>
            </div>
            <div class="preview-ruling">CASE CLOSED</div>
          </div>
          <div class="visual-note">SHARP WORK!</div>
        </div>
      </div>
    </section>

    <section class="ticker" aria-hidden="true">
      <div class="ticker-track">
        <div v-for="copy in 2" :key="copy" class="ticker-group">
          <span>SIX GUESSES</span><i>●</i><span>ONE VERDICT</span><i>●</i><span>EVERY DAY</span><i>●</i>
        </div>
      </div>
    </section>

    <section class="section mechanics-section">
      <div class="page-wrap">
        <div class="section-heading">
          <span class="eyebrow">The evidence</span>
          <h2>Every tile tells you something.</h2>
          <p>Each guess narrows the case. Color is the judge, and you have six rows to make your argument.</p>
        </div>
        <div class="mechanic-grid">
          <article class="mechanic-card mechanic-card--green">
            <div class="single-tile">V</div>
            <span>01 / HIT</span>
            <h3>Right letter.<br />Right place.</h3>
            <p>Green means the letter is locked exactly where it belongs.</p>
          </article>
          <article class="mechanic-card mechanic-card--yellow">
            <div class="single-tile">E</div>
            <span>02 / NEAR</span>
            <h3>Right letter.<br />Wrong place.</h3>
            <p>Yellow means the letter is in the answer, but needs to move.</p>
          </article>
          <article class="mechanic-card mechanic-card--gray">
            <div class="single-tile">X</div>
            <span>03 / MISS</span>
            <h3>Not in<br />the word.</h3>
            <p>Gray removes a suspect. Use the space it leaves wisely.</p>
          </article>
        </div>
      </div>
    </section>

    <section class="section ritual-section">
      <div class="page-wrap ritual-grid">
        <div class="ritual-visual surface">
          <div class="streak-badge"><Flame :size="30" fill="currentColor" /> 12</div>
          <div class="calendar-strip">
            <div v-for="(day, index) in ['M', 'T', 'W', 'T', 'F', 'S', 'S']" :key="`${day}-${index}`" :class="{ active: index < 6 }">
              <span>{{ day }}</span>
              <strong>{{ index < 6 ? '✓' : '·' }}</strong>
            </div>
          </div>
          <div class="ritual-callout"><BellRing :size="22" /> Your streak is on the line.</div>
        </div>
        <div class="ritual-copy">
          <span class="eyebrow">A daily ritual</span>
          <h2>Five minutes.<br />One satisfying win.</h2>
          <p>A fresh puzzle arrives at midnight UTC. Build your streak, sharpen your opening word, and compare your spoiler-free grid.</p>
          <ul>
            <li><Flame :size="21" /> Local streak and win history</li>
            <li><Share2 :size="21" /> One-tap, spoiler-safe sharing</li>
            <li><BellRing :size="21" /> Daily rhythm, never an endless feed</li>
          </ul>
          <RouterLink class="button button--green" to="/play">Start today’s case <ArrowRight :size="20" /></RouterLink>
        </div>
      </div>
    </section>

    <section class="section modes-section">
      <div class="page-wrap">
        <div class="modes-heading">
          <div>
            <span class="eyebrow">Coming to the docket</span>
            <h2>Same rules.<br />New pressure.</h2>
          </div>
          <p>Twist modes are being built on the same clean core. Each one changes a single constraint, and the entire puzzle feels new.</p>
        </div>
        <div class="mode-grid">
          <article v-for="mode in modes" :key="mode.name" class="mode-card" :class="`mode-card--${mode.color}`">
            <div class="mode-card-top"><span>{{ mode.code }}</span><component :is="mode.icon" :size="26" :stroke-width="2.5" /></div>
            <h3>{{ mode.name }}</h3>
            <p>{{ mode.copy }}</p>
            <span class="coming-label">Coming soon</span>
          </article>
        </div>
      </div>
    </section>

    <section class="final-cta">
      <div class="page-wrap final-cta-inner">
        <span class="cta-stamp">TODAY’S CASE IS OPEN</span>
        <h2>What’s your verdict?</h2>
        <p>There is only one way to find out.</p>
        <RouterLink class="button button--white" to="/play">Play free now <ArrowRight :size="21" :stroke-width="3" /></RouterLink>
      </div>
    </section>
  </div>
</template>

<style scoped>
.hero {
  position: relative;
  overflow: hidden;
  padding: 86px 0 100px;
  border-bottom: var(--border);
}

.hero-grid {
  display: grid;
  grid-template-columns: 1.08fr 0.92fr;
  align-items: center;
  gap: clamp(40px, 8vw, 100px);
}

.hero-copy {
  position: relative;
  z-index: 2;
}

.live-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--green);
  box-shadow: 0 0 0 3px rgb(67 196 122 / 20%);
}

.hero h1 {
  max-width: 760px;
  margin-bottom: 28px;
}

.hero h1 span {
  position: relative;
  display: inline-block;
  z-index: 0;
}

.hero h1 span::after {
  position: absolute;
  z-index: -1;
  right: -6px;
  bottom: 2px;
  left: -6px;
  height: 28%;
  background: var(--yellow);
  content: '';
  transform: rotate(-1deg);
}

.hero-copy > p {
  max-width: 600px;
  margin-bottom: 32px;
  font-size: 1.18rem;
}

.hero-actions {
  display: flex;
  align-items: center;
  gap: 28px;
  margin-bottom: 48px;
}

.text-link {
  font-weight: 700;
  text-decoration-thickness: 3px;
  text-underline-offset: 5px;
}

.hero-proof {
  display: flex;
  gap: 34px;
}

.hero-proof div {
  display: flex;
  flex-direction: column;
}

.hero-proof strong {
  font-size: 1.75rem;
  line-height: 1;
}

.hero-proof span {
  margin-top: 5px;
  color: #625f59;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
}

.hero-visual {
  position: relative;
  width: min(100%, 460px);
  justify-self: end;
  padding: 22px;
}

.preview-card {
  position: relative;
  z-index: 2;
  padding: clamp(22px, 5vw, 36px);
  border: 4px solid var(--ink);
  background: var(--white);
  box-shadow: 12px 12px 0 var(--ink);
  transform: rotate(1.5deg);
}

.preview-card-top {
  display: flex;
  justify-content: space-between;
  margin-bottom: 22px;
  padding-bottom: 12px;
  border-bottom: 3px solid var(--ink);
  font-weight: 700;
  letter-spacing: 0.08em;
}

.preview-board {
  display: grid;
  gap: 7px;
}

.preview-row {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 7px;
}

.preview-tile {
  display: grid;
  aspect-ratio: 1;
  place-items: center;
  border: 3px solid var(--ink);
  box-shadow: 3px 3px 0 var(--ink);
  font-size: clamp(1rem, 3vw, 1.6rem);
  font-weight: 700;
}

.preview-tile--hit { background: var(--green); }
.preview-tile--near { background: var(--yellow); }
.preview-tile--miss { background: var(--miss); color: var(--white); }
.preview-tile--empty { background: var(--paper); box-shadow: none; }

.preview-ruling {
  margin-top: 24px;
  padding: 9px;
  border: var(--border);
  background: var(--green);
  box-shadow: 4px 4px 0 var(--ink);
  font-size: 0.82rem;
  font-weight: 700;
  letter-spacing: 0.13em;
  text-align: center;
}

.case-label,
.visual-note {
  position: absolute;
  z-index: 3;
  padding: 8px 14px;
  border: var(--border);
  box-shadow: var(--shadow-small);
  font-weight: 700;
}

.case-label {
  top: 2px;
  left: -12px;
  background: var(--coral);
  transform: rotate(-7deg);
}

.visual-note {
  right: -5px;
  bottom: 2px;
  background: var(--yellow);
  transform: rotate(6deg);
}

.hero-shape {
  position: absolute;
  border: var(--border);
  pointer-events: none;
}

.hero-shape--one {
  top: 70px;
  right: -80px;
  width: 240px;
  height: 240px;
  background: var(--blue);
  transform: rotate(24deg);
}

.hero-shape--two {
  bottom: -80px;
  left: -90px;
  width: 210px;
  height: 150px;
  background: var(--purple);
  transform: rotate(-16deg);
}

.ticker {
  overflow: hidden;
  border-bottom: var(--border);
  background: var(--yellow);
  transform: rotate(-0.4deg) scale(1.01);
}

.ticker-track {
  display: flex;
  width: max-content;
  align-items: center;
  padding: 15px 0;
  font-size: 0.95rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  animation: ticker 26s linear infinite;
}

.ticker-group {
  display: flex;
  min-width: 100vw;
  flex-shrink: 0;
  align-items: center;
  justify-content: space-around;
  gap: 28px;
  padding-right: 28px;
}

.ticker i {
  font-style: normal;
}

@keyframes ticker { to { transform: translateX(-50%); } }

.mechanics-section {
  background: var(--paper);
}

.mechanic-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 26px;
}

.mechanic-card {
  position: relative;
  min-height: 410px;
  padding: 30px;
  border: var(--border);
  box-shadow: var(--shadow);
}

.mechanic-card--green { background: var(--green); }
.mechanic-card--yellow { background: var(--yellow); }
.mechanic-card--gray { background: #a7a39c; }

.single-tile {
  display: grid;
  width: 86px;
  height: 86px;
  margin-bottom: 60px;
  place-items: center;
  border: var(--border);
  background: var(--white);
  box-shadow: 5px 5px 0 var(--ink);
  font-size: 2.6rem;
  font-weight: 700;
  transform: rotate(-3deg);
}

.mechanic-card:nth-child(2) .single-tile { transform: rotate(3deg); }
.mechanic-card span { font-size: 0.75rem; font-weight: 700; letter-spacing: 0.12em; }
.mechanic-card h3 { margin: 13px 0 18px; }
.mechanic-card p { margin-bottom: 0; font-weight: 520; }

.ritual-section {
  border-block: var(--border);
  background: var(--ink);
  color: var(--white);
}

.ritual-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: center;
  gap: clamp(50px, 9vw, 110px);
}

.ritual-visual {
  position: relative;
  padding: 58px 34px 36px;
  color: var(--ink);
  transform: rotate(-1.5deg);
}

.streak-badge {
  position: absolute;
  top: -26px;
  right: 28px;
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 13px 18px;
  border: var(--border);
  background: var(--coral);
  box-shadow: 5px 5px 0 var(--yellow);
  font-size: 1.6rem;
  font-weight: 700;
  transform: rotate(5deg);
}

.calendar-strip {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  border: var(--border);
}

.calendar-strip div {
  display: grid;
  min-width: 0;
  place-items: center;
  padding: 12px 2px;
  background: var(--paper-deep);
}

.calendar-strip div + div { border-left: 2px solid var(--ink); }
.calendar-strip div.active { background: var(--green); }
.calendar-strip span { font-size: 0.68rem; font-weight: 700; }
.calendar-strip strong { margin-top: 7px; font-size: 1.25rem; }

.ritual-callout {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 24px;
  padding: 14px;
  border: var(--border);
  background: var(--yellow);
  font-weight: 700;
}

.ritual-copy .eyebrow { color: var(--ink); }
.ritual-copy h2 { margin-bottom: 26px; }
.ritual-copy > p { max-width: 580px; color: #d1ccc3; font-size: 1.1rem; }
.ritual-copy ul { display: grid; gap: 13px; margin: 28px 0 34px; padding: 0; list-style: none; }
.ritual-copy li { display: flex; align-items: center; gap: 11px; font-weight: 600; }
.ritual-copy li svg { color: var(--yellow); }

.modes-section { background: var(--blue); }
.modes-heading { display: grid; grid-template-columns: 1.2fr 0.8fr; align-items: end; gap: 50px; margin-bottom: 50px; }
.modes-heading h2, .modes-heading p { margin-bottom: 0; }
.modes-heading p { font-size: 1.08rem; font-weight: 520; }
.mode-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; }
.mode-card { min-height: 330px; padding: 24px; border: var(--border); box-shadow: 5px 5px 0 var(--ink); }
.mode-card--yellow { background: var(--yellow); }
.mode-card--coral { background: var(--coral); }
.mode-card--blue { background: var(--white); }
.mode-card--purple { background: var(--purple); }
.mode-card-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 70px; }
.mode-card-top span { font-weight: 700; }
.mode-card h3 { margin-bottom: 14px; font-size: 2rem; text-transform: uppercase; }
.mode-card p { min-height: 75px; margin-bottom: 20px; line-height: 1.45; }
.coming-label { display: inline-block; padding-top: 10px; border-top: 2px solid var(--ink); font-size: 0.7rem; font-weight: 700; letter-spacing: 0.11em; text-transform: uppercase; }

.final-cta {
  padding: 110px 0;
  border-top: var(--border);
  background: var(--coral);
  text-align: center;
}
.final-cta-inner { display: flex; flex-direction: column; align-items: center; }
.cta-stamp { display: inline-block; margin-bottom: 30px; padding: 8px 13px; border: var(--border); background: var(--yellow); box-shadow: 4px 4px 0 var(--ink); font-size: 0.75rem; font-weight: 700; letter-spacing: 0.12em; transform: rotate(-2deg); }
.final-cta h2 { margin-bottom: 16px; font-size: clamp(3rem, 8vw, 7rem); }
.final-cta p { margin-bottom: 28px; font-size: 1.2rem; font-weight: 600; }
.final-cta .button { width: auto; }

@media (max-width: 920px) {
  .hero-grid { grid-template-columns: 1fr; }
  .hero-copy { text-align: center; }
  .hero-copy > p { margin-inline: auto; }
  .hero-actions, .hero-proof { justify-content: center; }
  .hero-visual { justify-self: center; }
  .mechanic-grid { grid-template-columns: 1fr; }
  .mechanic-card { min-height: 0; }
  .single-tile { margin-bottom: 35px; }
  .ritual-grid { grid-template-columns: 1fr; }
  .ritual-visual { order: 2; }
  .mode-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 620px) {
  .hero { padding: 62px 0 74px; }
  .hero-actions { flex-direction: column; gap: 22px; }
  .hero-actions .button { width: 100%; }
  .hero-proof { justify-content: space-between; gap: 10px; }
  .hero-visual { padding-inline: 4px; }
  .case-label { left: -4px; }
  .visual-note { right: -3px; }
  .mechanic-card { padding: 24px; }
  .ritual-visual { padding-inline: 18px; }
  .calendar-strip div:nth-child(6), .calendar-strip div:nth-child(7) { display: none; }
  .calendar-strip { grid-template-columns: repeat(5, 1fr); }
  .modes-heading { grid-template-columns: 1fr; gap: 24px; }
  .mode-grid { grid-template-columns: 1fr; }
  .mode-card { min-height: 280px; }
  .final-cta { padding: 80px 0; }
}
</style>
