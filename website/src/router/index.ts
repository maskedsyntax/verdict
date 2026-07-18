import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', name: 'home', component: () => import('@/pages/HomePage.vue') },
    { path: '/play', name: 'play', component: () => import('@/pages/GamePage.vue') },
    { path: '/stats', name: 'stats', component: () => import('@/pages/StatsPage.vue') },
    { path: '/how-to-play', name: 'how-to-play', component: () => import('@/pages/HowToPage.vue') },
    { path: '/privacy', name: 'privacy', component: () => import('@/pages/PrivacyPage.vue') },
    { path: '/terms', name: 'terms', component: () => import('@/pages/TermsPage.vue') },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
  scrollBehavior: () => ({ top: 0 }),
})

router.afterEach((to) => {
  const titles: Record<string, string> = {
    home: 'Verdict | Six guesses. One verdict.',
    play: 'Play today’s Verdict',
    stats: 'Your Verdict stats',
    'how-to-play': 'How to play Verdict',
    privacy: 'Privacy policy | Verdict',
    terms: 'Terms of use | Verdict',
  }
  document.title = titles[String(to.name)] ?? 'Verdict'
})

export default router
