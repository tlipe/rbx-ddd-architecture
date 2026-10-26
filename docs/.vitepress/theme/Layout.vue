<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { useRoute } from 'vitepress'
import { computed } from 'vue'
import Home from './Home.vue'

const { Layout } = DefaultTheme
const route = useRoute()

const isHome = computed(() => {
  return route.path === '/' || route.path === '/index.html'
})
</script>

<template>
  <Home v-if="isHome" />
  <Layout v-else />
</template>
