<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { useRoute, useData } from 'vitepress'
import { computed } from 'vue'
import Home from './Home.vue'

const { Layout } = DefaultTheme
const route = useRoute()
const { site } = useData()

const isHome = computed(() => {
  const base = site.value.base || '/'
  const normalizedBase = base.endsWith('/') ? base : base + '/'
  const path = route.path
  return path === '/' || path === '/index.html' || path === normalizedBase || path === normalizedBase + 'index.html'
})
</script>

<template>
  <Home v-if="isHome" />
  <Layout v-else />
</template>
