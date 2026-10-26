---
layout: home

hero:
  name: "RBX DDD Architecture"
  text: "Domain-Driven Design for Roblox Studio"
  tagline: Clean layers, typed boundaries, zero ceremony.
  actions:
    - theme: brand
      text: Get Started
      link: /guide/installation
    - theme: alt
      text: GitHub
      link: https://github.com/tlipe/rbx-ddd-architecture
---

<script setup>
import { ref } from 'vue'

const concepts = ref([
  {
    title: 'Server-Authoritative',
    body: 'All state lives on the server. Clients render; they never own truth.',
    icon: 'server',
  },
  {
    title: 'Typed Contracts',
    body: 'Luau types define every module boundary. No untyped Remote traffic.',
    icon: 'typed',
  },
  {
    title: 'Hot-Reload Ready',
    body: 'Registry wiring survives Studio reloads without manual teardown.',
    icon: 'reload',
  },
])
</script>

<div class="custom-home">
  <section class="concepts-section">
    <div class="concepts-grid">
      <article v-for="concept in concepts" :key="concept.title" class="concept-card">
        <div class="concept-icon">
          <svg v-if="concept.icon === 'server'" width="32" height="32" viewBox="0 0 32 32" fill="none">
            <rect x="4" y="6" width="24" height="8" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
            <rect x="4" y="18" width="24" height="8" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
            <circle cx="8" cy="10" r="1.5" fill="var(--vp-c-brand-1)"/>
            <circle cx="8" cy="22" r="1.5" fill="var(--vp-c-brand-1)"/>
          </svg>
          <svg v-else-if="concept.icon === 'typed'" width="32" height="32" viewBox="0 0 32 32" fill="none">
            <path d="M6 4h14l6 6v18H6z" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
            <path d="M20 4v6h6" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
            <path d="M10 16h10M10 20h10M10 24h7" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
          </svg>
          <svg v-else width="32" height="32" viewBox="0 0 32 32" fill="none">
            <path d="M18 3L7 18h7l-2 11L23 14h-7z" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none" stroke-linejoin="round"/>
          </svg>
        </div>
        <h2 class="concept-title">{{ concept.title }}</h2>
        <p class="concept-body">{{ concept.body }}</p>
      </article>
    </div>
  </section>

  <section class="manifesto-section">
    <blockquote class="manifesto-quote">
      Structure without ceremony. Convention over configuration.
    </blockquote>
  </section>

  <footer class="home-footer">
    <span class="footer-license">MPL-2.0 License</span>
    <a class="footer-link" href="https://github.com/tlipe/rbx-ddd-architecture" rel="noopener">
      github.com/tlipe/rbx-ddd-architecture
    </a>
  </footer>
</div>

<style>
.custom-home {
  background-color: var(--vp-c-bg);
  padding: 64px 0;
}

.concepts-section {
  max-width: 960px;
  margin: 0 auto;
  padding: 0 32px 64px;
}

.concepts-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.concept-card {
  background-color: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  padding: 32px;
  transition: all 200ms ease-out;
}

.concept-card:hover {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 0 20px rgba(139, 92, 246, 0.25);
  transform: translateY(-2px);
}

.concept-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(139, 92, 246, 0.1);
  border-radius: 8px;
  margin-bottom: 20px;
}

.concept-title {
  font-size: 16px;
  font-weight: 600;
  line-height: 1.5;
  color: var(--vp-c-text-1);
  margin: 0 0 8px;
}

.concept-body {
  font-size: 14px;
  font-weight: 400;
  line-height: 1.6;
  color: var(--vp-c-text-2);
  margin: 0;
}

.manifesto-section {
  background-color: var(--vp-c-bg-alt);
  border-top: 1px solid var(--vp-c-border);
  border-bottom: 1px solid var(--vp-c-border);
  padding: 64px 32px;
  position: relative;
}

.manifesto-quote {
  font-size: 20px;
  font-weight: 500;
  font-style: italic;
  line-height: 1.5;
  color: var(--vp-c-text-1);
  max-width: 65ch;
  margin: 0 auto;
  text-align: center;
}

.home-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 32px;
  background-color: var(--vp-c-bg);
  border-top: 1px solid var(--vp-c-border);
  max-width: 960px;
  margin: 0 auto;
}

.footer-license {
  font-size: 12px;
  font-weight: 500;
  color: var(--vp-c-text-2);
}

.footer-link {
  font-size: 12px;
  font-weight: 500;
  color: var(--vp-c-brand-3);
  text-decoration: none;
  transition: color 200ms ease-out;
}

.footer-link:hover {
  color: var(--vp-c-brand-1);
}

@media (max-width: 767px) {
  .concepts-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .concept-card {
    padding: 24px;
  }
  
  .manifesto-section {
    padding: 48px 16px;
  }
  
  .manifesto-quote {
    font-size: 18px;
  }
  
  .home-footer {
    padding: 16px;
    flex-direction: column;
    gap: 8px;
    text-align: center;
  }
}
</style>
