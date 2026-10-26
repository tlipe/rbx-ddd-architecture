<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { useData } from 'vitepress'
import { computed } from 'vue'
import Home from './Home.vue'

const { Layout } = DefaultTheme
const { frontmatter } = useData()

const isCustomHome = computed(() => {
  return frontmatter.value.customHome === true
})
</script>

<template>
  <Layout>
    <template #home-hero-before v-if="isCustomHome">
      <Home />
    </template>
  </Layout>
</template>
