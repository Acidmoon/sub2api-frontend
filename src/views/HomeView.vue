<template>
  <!-- Custom Home Content: Full Page Mode -->
  <div v-if="homeContent" class="min-h-screen">
    <iframe
      v-if="isHomeContentUrl"
      :src="homeContent.trim()"
      class="h-screen w-full border-0"
      allowfullscreen
    ></iframe>
    <!-- HTML mode - SECURITY: homeContent is admin-only setting, XSS risk is acceptable -->
    <div v-else v-html="homeContent"></div>
  </div>

  <!-- Default Home Page -->
  <div v-else class="flex min-h-screen flex-col bg-[var(--surface-page)] text-[var(--text-main)]">
    <header class="border-b border-[var(--line-subtle)] bg-[var(--surface-base)]/95 backdrop-blur">
      <nav class="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6">
        <div class="flex items-center gap-3">
          <div class="flex h-9 w-9 items-center justify-center overflow-hidden rounded-lg border border-[var(--line-subtle)] bg-[var(--surface-muted)]">
            <img :src="siteLogo || '/logo.png'" alt="Logo" class="h-full w-full object-contain" />
          </div>
          <span class="hidden text-sm font-semibold text-[var(--text-main)] sm:inline">{{ siteName }}</span>
        </div>

        <div class="flex items-center gap-2">
          <LocaleSwitcher />

          <a
            v-if="docUrl"
            :href="docUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex h-11 w-11 items-center justify-center rounded-lg text-[var(--text-muted)] transition-colors hover:bg-[var(--surface-muted)] hover:text-[var(--text-main)]"
            :title="t('home.viewDocs')"
            :aria-label="t('home.viewDocs')"
          >
            <Icon name="book" size="md" />
          </a>

          <button
            @click="toggleTheme"
            class="inline-flex h-11 w-11 items-center justify-center rounded-lg text-[var(--text-muted)] transition-colors hover:bg-[var(--surface-muted)] hover:text-[var(--text-main)]"
            :title="isDark ? t('home.switchToLight') : t('home.switchToDark')"
            :aria-label="isDark ? t('home.switchToLight') : t('home.switchToDark')"
          >
            <Icon v-if="isDark" name="sun" size="md" />
            <Icon v-else name="moon" size="md" />
          </button>

          <router-link
            :to="isAuthenticated ? dashboardPath : '/login'"
            class="btn btn-primary hidden px-4 sm:inline-flex"
          >
            {{ isAuthenticated ? t('home.dashboard') : t('home.login') }}
          </router-link>
        </div>
      </nav>
    </header>

    <main class="flex-1 px-4 py-12 sm:px-6 lg:py-16">
      <div class="mx-auto max-w-6xl">
        <section class="grid items-center gap-8 lg:grid-cols-[minmax(0,0.95fr)_minmax(420px,1.05fr)] lg:gap-12">
          <div>
            <div class="mb-5 inline-flex items-center gap-2 rounded-full border border-[var(--line-subtle)] bg-[var(--surface-base)] px-3 py-1.5 text-xs font-medium text-[var(--text-muted)]">
              <span class="h-1.5 w-1.5 rounded-full bg-[var(--success)]"></span>
              AI API Gateway
            </div>
            <h1 class="max-w-3xl text-4xl font-semibold leading-tight tracking-normal text-[var(--text-main)] md:text-5xl lg:text-6xl">
              {{ siteName }}
            </h1>
            <p class="mt-5 max-w-2xl text-base leading-7 text-[var(--text-muted)] md:text-lg">
              {{ siteSubtitle }}
            </p>
            <div class="mt-8 flex flex-col gap-3 sm:flex-row">
              <router-link :to="isAuthenticated ? dashboardPath : '/login'" class="btn btn-primary px-6">
                {{ isAuthenticated ? t('home.goToDashboard') : t('home.getStarted') }}
                <Icon name="arrowRight" size="md" class="ml-1" :stroke-width="2" />
              </router-link>
              <a
                v-if="docUrl"
                :href="docUrl"
                target="_blank"
                rel="noopener noreferrer"
                class="btn btn-secondary px-6"
              >
                <Icon name="book" size="md" />
                {{ t('home.docs') }}
              </a>
            </div>
          </div>

          <div class="quiet-panel overflow-hidden">
            <div class="flex items-center justify-between border-b border-[var(--line-subtle)] px-4 py-3">
              <div class="flex items-center gap-2">
                <span class="h-2.5 w-2.5 rounded-full bg-[var(--danger)]"></span>
                <span class="h-2.5 w-2.5 rounded-full bg-[var(--warning)]"></span>
                <span class="h-2.5 w-2.5 rounded-full bg-[var(--success)]"></span>
              </div>
              <span class="font-mono text-xs text-[var(--text-muted)]">gateway.request</span>
            </div>
            <div class="space-y-5 p-5">
              <div class="rounded-lg bg-[#0B1220] p-4 font-mono text-sm leading-7 text-slate-200 shadow-sm dark:bg-black/40">
                <div class="code-line line-1">
                  <span class="code-prompt">$</span>
                  <span class="code-cmd">curl</span>
                  <span class="code-flag">-X POST</span>
                  <span class="code-url">/v1/messages</span>
                </div>
                <div class="code-line line-2">
                  <span class="code-comment"># API Key accepted, scheduling upstream...</span>
                </div>
                <div class="code-line line-3">
                  <span class="code-success">200 OK</span>
                  <span class="code-response">{ "content": "Hello!" }</span>
                </div>
                <div class="code-line line-4">
                  <span class="code-prompt">$</span>
                  <span class="cursor"></span>
                </div>
              </div>

              <div class="grid gap-2 sm:grid-cols-4">
                <div class="route-node">API Key</div>
                <div class="route-node">Scheduler</div>
                <div class="route-node">Upstream</div>
                <div class="route-node text-[var(--success)]">200 OK</div>
              </div>
            </div>
          </div>
        </section>

        <section class="mt-10 grid gap-3 md:grid-cols-3">
          <div class="quiet-panel p-5">
            <Icon name="swap" size="md" class="mb-4 text-[var(--brand)]" />
            <h3 class="text-base font-semibold text-[var(--text-main)]">
              {{ t('home.tags.subscriptionToApi') }}
            </h3>
            <p class="mt-2 text-sm leading-6 text-[var(--text-muted)]">
              {{ t('home.features.unifiedGatewayDesc') }}
            </p>
          </div>
          <div class="quiet-panel p-5">
            <Icon name="shield" size="md" class="mb-4 text-[var(--brand)]" />
            <h3 class="text-base font-semibold text-[var(--text-main)]">
              {{ t('home.tags.stickySession') }}
            </h3>
            <p class="mt-2 text-sm leading-6 text-[var(--text-muted)]">
              {{ t('home.features.multiAccountDesc') }}
            </p>
          </div>
          <div class="quiet-panel p-5">
            <Icon name="chart" size="md" class="mb-4 text-[var(--brand)]" />
            <h3 class="text-base font-semibold text-[var(--text-main)]">
              {{ t('home.tags.realtimeBilling') }}
            </h3>
            <p class="mt-2 text-sm leading-6 text-[var(--text-muted)]">
              {{ t('home.features.balanceQuotaDesc') }}
            </p>
          </div>
        </section>

        <section class="mt-12">
          <div class="mb-5 flex flex-col justify-between gap-2 sm:flex-row sm:items-end">
            <div>
              <h2 class="text-2xl font-semibold text-[var(--text-main)]">
                {{ t('home.providers.title') }}
              </h2>
              <p class="mt-2 text-sm text-[var(--text-muted)]">
                {{ t('home.providers.description') }}
              </p>
            </div>
          </div>
          <div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
            <div class="provider-chip">
              <span class="provider-mark">C</span>
              <span>{{ t('home.providers.claude') }}</span>
              <span class="provider-state">{{ t('home.providers.supported') }}</span>
            </div>
            <div class="provider-chip">
              <span class="provider-mark">G</span>
              <span>GPT</span>
              <span class="provider-state">{{ t('home.providers.supported') }}</span>
            </div>
            <div class="provider-chip">
              <span class="provider-mark">G</span>
              <span>{{ t('home.providers.gemini') }}</span>
              <span class="provider-state">{{ t('home.providers.supported') }}</span>
            </div>
            <div class="provider-chip">
              <span class="provider-mark">A</span>
              <span>{{ t('home.providers.antigravity') }}</span>
              <span class="provider-state">{{ t('home.providers.supported') }}</span>
            </div>
            <div class="provider-chip opacity-70">
              <span class="provider-mark">+</span>
              <span>{{ t('home.providers.more') }}</span>
              <span class="provider-state muted">{{ t('home.providers.soon') }}</span>
            </div>
          </div>
        </section>
      </div>
    </main>

    <footer class="border-t border-[var(--line-subtle)] px-4 py-6 sm:px-6">
      <div class="mx-auto flex max-w-6xl flex-col items-center justify-between gap-3 text-center sm:flex-row sm:text-left">
        <p class="text-sm text-[var(--text-muted)]">
          &copy; {{ currentYear }} {{ siteName }}. {{ t('home.footer.allRightsReserved') }}
        </p>
        <div class="flex items-center gap-4">
          <a
            v-if="docUrl"
            :href="docUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="text-sm text-[var(--text-muted)] transition-colors hover:text-[var(--text-main)]"
          >
            {{ t('home.docs') }}
          </a>
          <a
            :href="githubUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="text-sm text-[var(--text-muted)] transition-colors hover:text-[var(--text-main)]"
          >
            GitHub
          </a>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuthStore, useAppStore } from '@/stores'
import LocaleSwitcher from '@/components/common/LocaleSwitcher.vue'
import Icon from '@/components/icons/Icon.vue'

const { t } = useI18n()

const authStore = useAuthStore()
const appStore = useAppStore()

const siteName = computed(() => appStore.cachedPublicSettings?.site_name || appStore.siteName || 'Sub2API')
const siteLogo = computed(() => appStore.cachedPublicSettings?.site_logo || appStore.siteLogo || '')
const siteSubtitle = computed(() => appStore.cachedPublicSettings?.site_subtitle || 'AI API Gateway Platform')
const docUrl = computed(() => appStore.cachedPublicSettings?.doc_url || appStore.docUrl || '')
const homeContent = computed(() => appStore.cachedPublicSettings?.home_content || '')

const isHomeContentUrl = computed(() => {
  const content = homeContent.value.trim()
  return content.startsWith('http://') || content.startsWith('https://')
})

const isDark = ref(document.documentElement.classList.contains('dark'))
const githubUrl = 'https://github.com/Wei-Shaw/sub2api'
const isAuthenticated = computed(() => authStore.isAuthenticated)
const isAdmin = computed(() => authStore.isAdmin)
const dashboardPath = computed(() => isAdmin.value ? '/admin/dashboard' : '/dashboard')
const currentYear = computed(() => new Date().getFullYear())

function toggleTheme() {
  isDark.value = !isDark.value
  document.documentElement.classList.toggle('dark', isDark.value)
  localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
}

function initTheme() {
  const savedTheme = localStorage.getItem('theme')
  if (
    savedTheme === 'dark' ||
    (!savedTheme && window.matchMedia('(prefers-color-scheme: dark)').matches)
  ) {
    isDark.value = true
    document.documentElement.classList.add('dark')
  }
}

onMounted(() => {
  initTheme()
  authStore.checkAuth()

  if (!appStore.publicSettingsLoaded) {
    appStore.fetchPublicSettings()
  }
})
</script>

<style scoped>
.code-line {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem;
  opacity: 0;
  animation: line-appear 420ms ease forwards;
}

.line-1 {
  animation-delay: 120ms;
}

.line-2 {
  animation-delay: 360ms;
}

.line-3 {
  animation-delay: 620ms;
}

.line-4 {
  animation-delay: 880ms;
}

.code-prompt {
  color: #34d399;
  font-weight: 700;
}

.code-cmd {
  color: #7dd3fc;
}

.code-flag {
  color: #c4b5fd;
}

.code-url {
  color: #5eead4;
}

.code-comment {
  color: #94a3b8;
  font-style: italic;
}

.code-success {
  border-radius: 4px;
  background: rgb(22 163 74 / 0.16);
  padding: 0.125rem 0.5rem;
  color: #86efac;
  font-weight: 600;
}

.code-response {
  color: #fbbf24;
}

.cursor {
  display: inline-block;
  width: 8px;
  height: 16px;
  background: #34d399;
  animation: blink 1s step-end infinite;
}

.route-node {
  min-height: 2.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--line-subtle);
  border-radius: 8px;
  background: var(--surface-muted);
  color: var(--text-muted);
  font-family: 'Fira Code', ui-monospace, monospace;
  font-size: 0.75rem;
  font-weight: 600;
}

.provider-chip {
  min-height: 4rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  border: 1px solid var(--line-subtle);
  border-radius: 8px;
  background: var(--surface-base);
  padding: 0.75rem;
  color: var(--text-main);
  box-shadow: var(--shadow-panel);
}

.provider-mark {
  display: inline-flex;
  width: 2rem;
  height: 2rem;
  flex: 0 0 2rem;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--line-subtle);
  border-radius: 8px;
  background: var(--surface-muted);
  color: var(--brand);
  font-weight: 700;
}

.provider-state {
  margin-left: auto;
  border-radius: 999px;
  background: var(--brand-soft);
  padding: 0.125rem 0.5rem;
  color: var(--brand);
  font-size: 0.6875rem;
  font-weight: 600;
}

.provider-state.muted {
  background: var(--surface-muted);
  color: var(--text-muted);
}

@keyframes line-appear {
  from {
    opacity: 0;
    transform: translateY(4px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes blink {
  0%,
  50% {
    opacity: 1;
  }
  51%,
  100% {
    opacity: 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .code-line,
  .cursor {
    animation: none;
    opacity: 1;
  }
}
</style>
