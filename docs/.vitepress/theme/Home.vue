<script setup lang="ts">
const concepts = [
  {
    title: 'Server-Authoritative',
    body: 'All state lives on the server. Clients render; they never own truth.',
    wide: true,
  },
  {
    title: 'Typed Contracts',
    body: 'Luau types define every module boundary. No untyped Remote traffic.',
    wide: false,
  },
  {
    title: 'Hot-Reload Ready',
    body: 'Registry wiring survives Studio reloads without manual teardown.',
    wide: false,
  },
]
</script>

<template>
  <div class="home">
    <section class="hero">
      <div class="hero-left">
        <h1 class="hero-title">RBX DDD Architecture</h1>
        <p class="hero-subtitle">
          A domain-driven foundation for Roblox Luau projects: clean layers,
          typed boundaries, zero ceremony.
        </p>
        <div class="hero-actions">
          <a class="btn btn-primary" href="/rbx-ddd-architecture/guide/installation">Get Started</a>
          <a class="btn btn-secondary" href="https://github.com/tlipe/rbx-ddd-architecture" rel="noopener">GitHub</a>
        </div>
      </div>
      <div class="hero-right">
        <img
          src="https://pixabay.com/get/gc0af2e80ad114af77ca06ddab5eb2df75a6f4f4d21bde8224ca1fb5c8f04e63d3ddf5d4c0b8ab28e5327f2f90bc5cc8a4dbb5a64f344c4fe8311e0ae69d3a11c_1280.jpg"
          alt="Abstract technology network visualization"
          loading="lazy"
          class="hero-image"
        />
      </div>
    </section>

    <section class="concepts">
      <article
        v-for="concept in concepts"
        :key="concept.title"
        class="cell"
        :class="{ 'cell-wide': concept.wide }"
      >
        <div class="cell-icon">
          <svg
            v-if="concept.title === 'Server-Authoritative'"
            width="16" height="16" viewBox="0 0 16 16" fill="none"
            stroke="#3b82f6" stroke-width="1.5" aria-hidden="true"
          >
            <rect x="2" y="2" width="12" height="4" />
            <rect x="2" y="10" width="12" height="4" />
            <circle cx="5" cy="4" r="0.5" fill="#3b82f6" />
            <circle cx="5" cy="12" r="0.5" fill="#3b82f6" />
          </svg>
          <svg
            v-else-if="concept.title === 'Typed Contracts'"
            width="16" height="16" viewBox="0 0 16 16" fill="none"
            stroke="#3b82f6" stroke-width="1.5" aria-hidden="true"
          >
            <path d="M3 1.5h7l3 3v10H3z" />
            <path d="M10 1.5v3h3" />
            <path d="M5.5 8h5M5.5 10.5h5" />
          </svg>
          <svg
            v-else
            width="16" height="16" viewBox="0 0 16 16" fill="none"
            stroke="#3b82f6" stroke-width="1.5" aria-hidden="true"
          >
            <path d="M9 1.5 3.5 9H7l-1 5.5L13.5 7H10z" />
          </svg>
        </div>
        <h2 class="cell-title">{{ concept.title }}</h2>
        <p class="cell-body">{{ concept.body }}</p>
      </article>
    </section>

    <section class="manifesto">
      <blockquote class="manifesto-line">
        Structure without ceremony. Convention over configuration.
      </blockquote>
    </section>

    <footer class="strip">
      <span class="strip-license">MPL-2.0 License</span>
      <a
        class="strip-link"
        href="https://github.com/tlipe/rbx-ddd-architecture"
        rel="noopener"
      >github.com/tlipe/rbx-ddd-architecture</a>
    </footer>
  </div>
</template>

<style scoped>
.home {
  background-color: #0a0e1a;
}

.hero {
  display: grid;
  grid-template-columns: 60fr 40fr;
  gap: 24px;
  align-items: center;
  padding: 48px 32px;
  max-width: 1280px;
  margin: 0 auto;
}

.hero-left {
  animation: fadeIn 200ms ease-out both;
}

.hero-title {
  font-family: Inter, -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 36px;
  font-weight: 700;
  line-height: 1.2;
  letter-spacing: -0.02em;
  color: #e2e8f0;
  margin: 0 0 12px;
}

.hero-subtitle {
  font-size: 14px;
  font-weight: 400;
  line-height: 1.5;
  color: #94a3b8;
  max-width: 48ch;
  margin: 0 0 24px;
}

.hero-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.btn {
  display: inline-block;
  font-family: Inter, -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 12px;
  font-weight: 500;
  line-height: 1;
  padding: 8px 16px;
  border-radius: 9999px;
  text-decoration: none;
  transition: box-shadow 200ms ease-out, background-color 200ms ease-out;
}

.btn-primary {
  background: linear-gradient(135deg, #1e40af, #3b82f6);
  color: #ffffff;
  border: none;
}

.btn-primary:hover {
  box-shadow: 0 0 12px rgba(59, 130, 246, 0.3);
}

.btn-secondary {
  background: transparent;
  color: #60a5fa;
  border: 1px solid #3b82f6;
}

.btn-secondary:hover {
  background-color: rgba(59, 130, 246, 0.1);
}

.hero-right {
  background-color: #0f1629;
  border: 1px solid #1e293b;
  border-radius: 0;
  overflow: hidden;
  animation: fadeIn 200ms ease-out 60ms both;
}

.hero-image {
  display: block;
  width: 100%;
  height: auto;
  object-fit: cover;
  filter: brightness(0.7) contrast(1.2) saturate(0.8);
}

.concepts {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 12px;
  padding: 0 32px 48px;
  max-width: 1280px;
  margin: 0 auto;
}

.cell {
  background-color: #0f1629;
  border: 1px solid #1e293b;
  border-radius: 0;
  padding: 24px;
  transition: box-shadow 200ms ease-out;
}

.cell:hover {
  box-shadow: 0 0 12px rgba(59, 130, 246, 0.3);
}

.cell-icon {
  margin-bottom: 12px;
}

.cell-title {
  font-size: 14px;
  font-weight: 600;
  line-height: 1.5;
  color: #e2e8f0;
  margin: 0 0 4px;
}

.cell-body {
  font-size: 14px;
  font-weight: 400;
  line-height: 1.5;
  color: #94a3b8;
  margin: 0;
  max-width: 48ch;
}

.manifesto {
  background-color: #111827;
  border-top: 1px solid #1e293b;
  border-bottom: 1px solid #1e293b;
  padding: 48px 32px;
}

.manifesto-line {
  font-family: Inter, -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 14px;
  font-weight: 600;
  font-style: italic;
  line-height: 1.5;
  color: #e2e8f0;
  max-width: 65ch;
  margin: 0 auto;
  text-align: center;
}

.strip {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 48px;
  padding: 0 32px;
  background-color: #0a0e1a;
  border-top: 1px solid #1e293b;
}

.strip-license {
  font-size: 12px;
  font-weight: 500;
  color: #94a3b8;
}

.strip-link {
  font-size: 12px;
  font-weight: 500;
  color: #60a5fa;
  text-decoration: none;
  transition: color 200ms ease-out;
}

.strip-link:hover {
  color: #3b82f6;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (prefers-reduced-motion: reduce) {
  .hero-left,
  .hero-right {
    animation: none;
  }
}

@media (max-width: 767px) {
  .hero {
    grid-template-columns: 1fr;
    padding: 32px 16px;
  }

  .concepts {
    grid-template-columns: 1fr;
    padding: 0 16px 32px;
  }

  .manifesto {
    padding: 32px 16px;
  }

  .strip {
    padding: 0 16px;
  }
}
</style>