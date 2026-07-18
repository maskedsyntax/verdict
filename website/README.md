# Verdict website

Vue 3 web edition of Verdict, built as an independently deployable Vite app.

## Local development

```sh
npm install
npm run dev
```

The website imports the shared answer and valid-guess lists from `../assets/words`, keeping its UTC puzzle selection aligned with the Dart engine.

## AdSense activation

1. Copy `.env.example` to `.env.production` in the deployment environment.
2. Set the approved AdSense publisher ID and the two responsive display-unit slot IDs.
3. Disable **Auto ads** for the site in AdSense. Verdict renders manual units only after a completed game and on `/stats`; Auto ads could otherwise place ads on the active puzzle.
4. Configure Google Funding Choices or another Google-certified CMP for regions where consent is required.
5. Build and deploy. The Vite build generates `/ads.txt` from `VITE_ADSENSE_CLIENT` automatically.

Set `VITE_CONTACT_EMAIL` to publish a support address in the footer, privacy policy, and terms.

When credentials are absent, development shows labeled placeholders and production renders no ad container. Ad loading failures and blockers do not interrupt gameplay.

## Deployment

```sh
npm run typecheck
npm run test
npm run build
```

Deploy `dist/` to any static host. Configure an SPA fallback so unknown application routes resolve to `index.html`. The host must serve `/ads.txt` as a plain text file without rewriting it.
