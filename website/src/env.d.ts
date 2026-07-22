/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_ADSENSE_CLIENT?: string
  readonly VITE_ADSENSE_RESULTS_SLOT?: string
  readonly VITE_ADSENSE_STATS_SLOT?: string
  readonly VITE_ADSENSE_HOME_SLOT?: string
  readonly VITE_ADSENSE_HOWTO_SLOT?: string
  readonly VITE_CONTACT_EMAIL?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

interface Window {
  adsbygoogle?: Record<string, unknown>[]
}
