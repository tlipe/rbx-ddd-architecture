<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vitepress'

const route = useRoute()
const currentLang = ref('en')
const isLoaded = ref(false)

const languages = [
  { code: 'en', name: 'English', flag: '🇺🇸' },
  { code: 'es', name: 'Español', flag: '🇪🇸' },
  { code: 'pt', name: 'Português', flag: '🇧🇷' },
  { code: 'fr', name: 'Français', flag: '🇫🇷' },
  { code: 'de', name: 'Deutsch', flag: '🇩🇪' },
  { code: 'it', name: 'Italiano', flag: '🇮🇹' },
  { code: 'ja', name: '日本語', flag: '🇯🇵' },
  { code: 'ko', name: '한국어', flag: '🇰🇷' },
  { code: 'zh-CN', name: '中文', flag: '🇨🇳' },
  { code: 'ru', name: 'Русский', flag: '🇷🇺' },
]

function detectLanguage(): string {
  const saved = localStorage.getItem('docs-language')
  if (saved) return saved

  const browserLang = navigator.language || (navigator as any).userLanguage
  if (!browserLang) return 'en'

  const langCode = browserLang.split('-')[0]
  const match = languages.find(l => l.code === langCode || l.code.startsWith(langCode))
  return match ? match.code : 'en'
}

function initGoogleTranslate() {
  if (typeof (window as any).google === 'undefined') {
    setTimeout(initGoogleTranslate, 100)
    return
  }

  isLoaded.value = true

  new (window as any).google.translate.TranslateElement(
    {
      pageLanguage: 'en',
      includedLanguages: languages.map(l => l.code).join(','),
      autoDisplay: false,
      layout: (window as any).google.translate.TranslateElement.InlineLayout.HORIZONTAL,
    },
    'google_translate_element'
  )

  const detectedLang = detectLanguage()
  if (detectedLang !== 'en') {
    changeLanguage(detectedLang)
  }
}

function changeLanguage(langCode: string) {
  currentLang.value = langCode
  localStorage.setItem('docs-language', langCode)

  if (langCode === 'en') {
    const cookie = document.cookie.split(';').find(c => c.trim().startsWith('googtrans='))
    if (cookie) {
      document.cookie = 'googtrans=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;'
      document.cookie = 'googtrans=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; domain=' + window.location.hostname
    }
    window.location.reload()
    return
  }

  const select = document.querySelector('.goog-te-combo') as HTMLSelectElement
  if (select) {
    select.value = langCode
    select.dispatchEvent(new Event('change'))
  }
}

onMounted(() => {
  initGoogleTranslate()
})

watch(() => route.path, () => {
  const saved = localStorage.getItem('docs-language')
  if (saved && saved !== 'en') {
    setTimeout(() => changeLanguage(saved), 300)
  }
})
</script>

<template>
  <div class="language-switcher">
    <div id="google_translate_element" style="display: none;"></div>
    <select v-model="currentLang" @change="changeLanguage(currentLang)" class="lang-select">
      <option v-for="lang in languages" :key="lang.code" :value="lang.code">
        {{ lang.flag }} {{ lang.name }}
      </option>
    </select>
  </div>
</template>

<style scoped>
.language-switcher {
  display: flex;
  align-items: center;
}

.lang-select {
  background: transparent;
  border: 1px solid var(--vp-c-border, #2e2e2e);
  color: var(--vp-c-text-1);
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 13px;
  font-family: Inter, -apple-system, BlinkMacSystemFont, sans-serif;
  cursor: pointer;
  transition: all 200ms ease-out;
}

.lang-select:hover {
  border-color: var(--vp-c-brand-1);
  background: rgba(139, 92, 246, 0.1);
}

.lang-select:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 0 0 2px rgba(139, 92, 246, 0.2);
}
</style>
