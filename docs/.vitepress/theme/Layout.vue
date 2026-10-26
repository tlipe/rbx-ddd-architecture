<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { computed } from 'vue'
import { useRoute } from 'vitepress'

const { Layout } = DefaultTheme

const route = useRoute()

const isHome = computed(() => {
  const path = route.path.replace(/\/index(\.html)?$/, '/')
  return path === '/' || path === '/rbx-ddd-architecture/'
})
</script>

<template>
  <div :class="{ 'sidebar-home': isHome }">
    <Layout />
  </div>
</template>

<style>
.sidebar-home {
  --vp-sidebar-width: 0px;
}

@media (min-width: 961px) {
  .sidebar-home .VPLayout,
  .sidebar-home main {
    padding-left: 0 !important;
  }
}
</style>