<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { computed, watchEffect } from 'vue'
import { useRoute } from 'vitepress'

const { Layout } = DefaultTheme

const route = useRoute()

const isHome = computed(() => {
  const path = route.path.replace(/\/index(\.html)?$/, '')
  return path === '/' || path === '' || path.endsWith('/index')
})

watchEffect(() => {
  if (typeof document !== 'undefined') {
    document.documentElement.classList.toggle('hide-sidebar', isHome.value)
  }
})
</script>

<template>
  <Layout />
</template>