import DefaultTheme from 'vitepress/theme'
import './custom.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ isBrowser }) {
    if (isBrowser) {
      document.documentElement.classList.add('dark')
      localStorage.setItem('vitepress-theme-appearance', 'dark')
    }
  },
}
