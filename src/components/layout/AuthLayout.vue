<template>
  <div class="relative flex min-h-dvh items-center justify-center bg-[var(--surface-page)] p-4 text-[var(--text-main)]">
    <div class="absolute inset-x-0 top-0 h-px bg-[var(--line-subtle)]"></div>

    <!-- Content Container -->
    <div class="relative z-10 w-full max-w-[440px]">
      <!-- Logo/Brand -->
      <div class="mb-6 text-center">
        <!-- Custom Logo or Default Logo -->
        <template v-if="settingsLoaded">
          <div
            class="mb-4 inline-flex h-12 w-12 items-center justify-center overflow-hidden rounded-lg border border-[var(--line-subtle)] bg-[var(--surface-base)]"
          >
            <img :src="siteLogo || '/logo.png'" alt="Logo" class="h-full w-full object-contain" />
          </div>
          <h1 class="mb-1 text-2xl font-semibold tracking-normal text-[var(--text-main)]">
            {{ siteName }}
          </h1>
          <p class="text-sm text-[var(--text-muted)]">
            {{ siteSubtitle }}
          </p>
        </template>
      </div>

      <!-- Card Container -->
      <div class="quiet-panel p-6 sm:p-7">
        <slot />
      </div>

      <!-- Footer Links -->
      <div class="mt-5 text-center text-sm">
        <slot name="footer" />
      </div>

      <!-- Copyright -->
      <div class="mt-7 text-center text-xs text-[var(--text-muted)]">
        &copy; {{ currentYear }} {{ siteName }}. All rights reserved.
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useAppStore } from '@/stores'
import { sanitizeUrl } from '@/utils/url'

const appStore = useAppStore()

const siteName = computed(() => appStore.siteName || 'Sub2API')
const siteLogo = computed(() => sanitizeUrl(appStore.siteLogo || '', { allowRelative: true, allowDataUrl: true }))
const siteSubtitle = computed(() => appStore.cachedPublicSettings?.site_subtitle || 'Subscription to API Conversion Platform')
const settingsLoaded = computed(() => appStore.publicSettingsLoaded)

const currentYear = computed(() => new Date().getFullYear())

onMounted(() => {
  appStore.fetchPublicSettings()
})
</script>
