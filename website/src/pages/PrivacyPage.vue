<script setup lang="ts">
const contactEmail = import.meta.env.VITE_CONTACT_EMAIL
</script>

<template>
  <div class="legal-page">
    <div class="page-wrap">
      <div class="page-intro">
        <span class="eyebrow">Plain-language policy</span>
        <h1>PRIVACY,<br />NO MYSTERY.</h1>
        <p>Verdict is designed to work without an account. This page explains what stays on your device and what advertising services may process.</p>
      </div>

      <article class="prose surface">
        <h2>Information stored on your device</h2>
        <p>Verdict stores your current puzzle, completed guesses, statistics, and streak in your browser’s local storage. This information remains on your device and lets you resume a game or view your record. Clearing site data removes it.</p>

        <h2>Advertising</h2>
        <p>We may use Google AdSense to display advertisements on completed-game results and statistics pages. Google and its partners may use cookies or similar technologies to serve, measure, and personalize advertisements where permitted.</p>
        <p>Where required, a Google-certified consent management platform will ask for your choices before personalized advertising technologies are used. You can revisit those choices through the privacy controls presented by that platform.</p>

        <h2>What we do not collect</h2>
        <ul>
          <li>No account, email address, or real name is required to play.</li>
          <li>Your typed guesses are not submitted to an advertising provider by Verdict.</li>
          <li>We do not sell personal information.</li>
        </ul>

        <h2>Third-party services</h2>
        <p>Google may process device, browser, approximate location, and ad-interaction information under its own policies. Learn more in <a href="https://policies.google.com/technologies/partner-sites" rel="noreferrer">Google’s explanation of data use on partner sites</a>.</p>

        <h2>Children</h2>
        <p>Verdict is a general-audience word game and is not directed to children under 13. We do not knowingly request personal information from children.</p>

        <h2>Changes and contact</h2>
        <p>We may update this policy as the service changes. Material revisions will be reflected here with a new effective date. <template v-if="contactEmail">Questions can be sent to <a :href="`mailto:${contactEmail}`">{{ contactEmail }}</a>.</template></p>
        <p><strong>Effective date:</strong> July 19, 2026</p>
      </article>
    </div>
  </div>
</template>
