<script setup lang="ts">
const contactEmail = import.meta.env.VITE_CONTACT_EMAIL
</script>

<template>
  <div class="legal-page">
    <div class="page-wrap">
      <div class="page-intro">
        <span class="eyebrow">Terms of the game</span>
        <h1>THE FAIR<br />PLAY FILE.</h1>
        <p>These terms cover your use of the Verdict website and daily word puzzle.</p>
      </div>

      <article class="prose surface">
        <h2>Using Verdict</h2>
        <p>You may use Verdict for personal, non-commercial entertainment. You agree not to interfere with the service, automate abusive traffic, bypass security controls, or attempt to manipulate future competitive features.</p>

        <h2>Availability</h2>
        <p>The game is provided on an “as available” basis. We may update word lists, features, visual design, or availability without notice. We do not guarantee uninterrupted service or preservation of locally stored game history.</p>

        <h2>Content and intellectual property</h2>
        <p>The Verdict name, visual identity, site copy, software, and original game presentation are protected by applicable intellectual property laws. The underlying word data is used under its respective open-source license.</p>

        <h2>Third-party advertising</h2>
        <p>Advertising shown through third-party providers may link to services we do not control. Your interaction with those advertisers is governed by their terms and policies.</p>

        <h2>No warranties</h2>
        <p>To the fullest extent permitted by law, Verdict is provided without warranties of merchantability, fitness for a particular purpose, or non-infringement. We are not liable for indirect or consequential loss arising from use of the service.</p>

        <h2>Changes and contact</h2>
        <p>Continued use after these terms change constitutes acceptance of the revised terms. <template v-if="contactEmail">Questions can be sent to <a :href="`mailto:${contactEmail}`">{{ contactEmail }}</a>.</template></p>
        <p><strong>Effective date:</strong> July 19, 2026</p>
      </article>
    </div>
  </div>
</template>
