<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { computed } from 'vue'
import { useRoute } from 'vitepress'

const Layout = DefaultTheme.Layout
const route = useRoute()

const isHome = computed(() => {
  const path = route.path.replace(/\.html$/, '').replace(/\/index$/, '')
  return path === '/' || path === '' || path === '/rbx-ddd-architecture' || path === '/rbx-ddd-architecture/'
})
</script>

<template>
  <div class="theme-wrapper" :class="{ 'hide-sidebar': isHome }">
    <Layout />
  </div>
</template>