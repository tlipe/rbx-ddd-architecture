import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'en',
  title: 'RBX DDD Architecture',
  description: 'Domain-Driven Design for Roblox Studio',
  base: '/rbx-ddd-architecture/',
  appearance: true,
  lastUpdated: true,
  cleanUrls: true,
  head: [
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    ['link', { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap' }]
  ],
  themeConfig: {
    darkModeSwitchLabel: 'Theme',
    outline: 'deep',
    nav: [
      { text: 'Guide', link: '/' },
      { text: 'GitHub', link: 'https://github.com/tlipe/rbx-ddd-architecture' }
    ],
    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Introduction', link: '/' },
          { text: 'Installation', link: '/guide/installation' }
        ]
      },
      {
        text: 'Architecture',
        items: [
          { text: 'Folder Reference', link: '/architecture/folder-reference' },
          { text: 'Contracts', link: '/architecture/contracts' },
          { text: 'Code Rules', link: '/architecture/code-rules' }
        ]
      },
      {
        text: 'Modules',
        items: [
          { text: 'Service', link: '/modules/service' },
          { text: 'Controller', link: '/modules/controller' },
          { text: 'Event', link: '/modules/event' },
          { text: 'Registry', link: '/modules/registry' },
          { text: 'HUD Frame', link: '/modules/hud-frame' }
        ]
      },
      {
        text: 'Debugging',
        items: [
          { text: 'Debugging', link: '/debugging/index' }
        ]
      }
    ]
  }
})