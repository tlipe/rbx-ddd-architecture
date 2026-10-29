<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import LanguageSwitcher from './LanguageSwitcher.vue'

const { Layout } = DefaultTheme
</script>

<template>
  <Layout v-bind="$attrs">
    <template v-for="(_, name) in $slots" :key="name" #[name]="slotData">
      <slot :name="name" v-bind="slotData || {}" />
    </template>
    <template #nav-bar-content-after>
      <ClientOnly>
        <LanguageSwitcher />
      </ClientOnly>
    </template>
  </Layout>
</template>
