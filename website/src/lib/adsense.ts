let scriptPromise: Promise<void> | null = null

export function loadAdsense(): Promise<void> {
  const client = import.meta.env.VITE_ADSENSE_CLIENT
  if (!client) return Promise.resolve()
  if (scriptPromise) return scriptPromise

  scriptPromise = new Promise((resolve, reject) => {
    const existing = document.querySelector<HTMLScriptElement>('script[data-verdict-adsense]')
    if (existing) {
      if (existing.dataset.loaded === 'true' || window.adsbygoogle) resolve()
      else existing.addEventListener('load', () => resolve(), { once: true })
      return
    }

    const script = document.createElement('script')
    script.async = true
    script.crossOrigin = 'anonymous'
    script.dataset.verdictAdsense = 'true'
    script.src = `https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${encodeURIComponent(client)}`
    script.addEventListener('load', () => {
      script.dataset.loaded = 'true'
      resolve()
    }, { once: true })
    script.addEventListener('error', () => reject(new Error('AdSense failed to load.')), { once: true })
    document.head.appendChild(script)
  })

  return scriptPromise
}
