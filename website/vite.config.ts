import { copyFileSync } from 'node:fs'
import { fileURLToPath, URL } from 'node:url'

import vue from '@vitejs/plugin-vue'
import { defineConfig, loadEnv, searchForWorkspaceRoot } from 'vite'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const publisherId = env.VITE_ADSENSE_CLIENT?.replace(/^ca-/, '')
  const workspaceRoot = fileURLToPath(new URL('..', import.meta.url))

  return {
    plugins: [
      vue(),
      {
        name: 'verdict-ads-txt',
        generateBundle() {
          if (!publisherId) return
          this.emitFile({
            type: 'asset',
            fileName: 'ads.txt',
            source: `google.com, ${publisherId}, DIRECT, f08c47fec0942fa0\n`,
          })
        },
      },
      {
        name: 'verdict-spa-fallback',
        writeBundle() {
          const dist = fileURLToPath(new URL('./dist', import.meta.url))
          copyFileSync(`${dist}/index.html`, `${dist}/404.html`)
        },
      },
    ],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
    server: {
      fs: {
        allow: [workspaceRoot, searchForWorkspaceRoot(process.cwd())],
      },
    },
    test: {
      environment: 'jsdom',
      environmentOptions: {
        jsdom: {
          url: 'http://localhost/',
        },
      },
      globals: true,
      css: true,
    },
  }
})
