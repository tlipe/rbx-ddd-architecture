<script setup lang="ts">
const concepts = [
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
]
</script>

<template>
  <div class="home">
    <section class="hero">
      <div class="hero-glow"></div>
      <div class="hero-grid"></div>
      <div class="hero-corner hero-corner-tl"></div>
      <div class="hero-corner hero-corner-tr"></div>
      <div class="hero-corner hero-corner-bl"></div>
      <div class="hero-corner hero-corner-br"></div>
      <div class="hero-accent hero-accent-1"></div>
      <div class="hero-accent hero-accent-2"></div>
      <div class="hero-accent hero-accent-3"></div>
      <div class="hero-content">
        <h1 class="hero-title">
          RBX <span class="gradient-text">DDD</span> Architecture
        </h1>
        <p class="hero-subtitle">
          A domain-driven foundation for Roblox Luau projects: clean layers,
          typed boundaries, zero ceremony.
        </p>
        <div class="hero-actions">
          <a class="btn btn-primary" href="/rbx-ddd-architecture/guide/installation">Get Started</a>
          <a class="btn btn-secondary" href="https://github.com/tlipe/rbx-ddd-architecture" rel="noopener">GitHub</a>
        </div>
      </div>
      <div class="hero-code">
        <div class="code-titlebar">
          <span class="code-dot"></span>
          <span class="code-dot"></span>
          <span class="code-dot"></span>
          <span class="code-filename">Domain/PlayerService.luau</span>
        </div>
        <div class="code-body-wrapper">
          <div class="code-gutter">
            <span>1</span><span>2</span><span>3</span><span>4</span><span>5</span>
            <span>6</span><span>7</span><span>8</span><span>9</span><span>10</span>
          </div>
          <pre class="code-body"><code><span class="code-comment">-- Domain/PlayerService.luau</span>
<span class="code-keyword">local</span> PlayerService = {}

<span class="code-keyword">function</span> <span class="code-fn">PlayerService.new</span>(): PlayerService
  <span class="code-keyword">local</span> self = <span class="code-fn">setmetatable</span>({}, {
    __index = PlayerService,
  })
  <span class="code-keyword">return</span> self
<span class="code-keyword">end</span>

<span class="code-keyword">return</span> PlayerService</code></pre>
          <div class="code-fade"></div>
        </div>
      </div>
    </section>

    <div class="section-divider"></div>

    <section class="concepts">
      <article
        v-for="concept in concepts"
        :key="concept.title"
        class="card"
      >
        <div class="card-icon">
          <svg v-if="concept.icon === 'server'" width="32" height="32" viewBox="0 0 32 32" fill="none" aria-hidden="true">
            <rect x="4" y="6" width="24" height="8" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
            <rect x="4" y="18" width="24" height="8" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
            <circle cx="8" cy="10" r="1.5" fill="var(--vp-c-brand-1)"/>
            <circle cx="8" cy="22" r="1.5" fill="var(--vp-c-brand-1)"/>
          </svg>
          <svg v-else-if="concept.icon === 'typed'" width="32" height="32" viewBox="0 0 32 32" fill="none" aria-hidden="true">
            <path d="M6 4h14l6 6v18H6z" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
            <path d="M20 4v6h6" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
            <path d="M10 16h10M10 20h10M10 24h7" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none"/>
          </svg>
          <svg v-else width="32" height="32" viewBox="0 0 32 32" fill="none" aria-hidden="true">
            <path d="M18 3L7 18h7l-2 11L23 14h-7z" stroke="var(--vp-c-brand-1)" stroke-width="2" fill="none" stroke-linejoin="round"/>
          </svg>
        </div>
        <h2 class="card-title">{{ concept.title }}</h2>
        <p class="card-body">{{ concept.body }}</p>
      </article>
    </section>

    <section class="manifesto">
      <blockquote class="manifesto-line">
        Structure without ceremony. Convention over configuration.
      </blockquote>
    </section>

    <footer class="strip">
      <div class="strip-glow"></div>
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
  background-color: var(--vp-c-bg);
  padding-bottom: 0;
}

/* ============ HERO ============ */
.hero {
  position: relative;
  padding: 80px 32px 64px;
  max-width: 960px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 48px;
  align-items: center;
  overflow: hidden;
}

.hero-glow {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 100%;
  height: 100%;
  background: radial-gradient(ellipse 60% 50% at 50% 0%, rgba(139, 92, 246, 0.08), transparent);
  pointer-events: none;
  z-index: 0;
}

/* Dot grid background */
.hero-grid {
  position: absolute;
  inset: 0;
  background-image: radial-gradient(circle, rgba(139, 92, 246, 0.15) 1px, transparent 1px);
  background-size: 24px 24px;
  opacity: 0.4;
  pointer-events: none;
  z-index: 0;
  mask-image: radial-gradient(ellipse 80% 60% at 50% 40%, black 20%, transparent 70%);
  -webkit-mask-image: radial-gradient(ellipse 80% 60% at 50% 40%, black 20%, transparent 70%);
}

/* Corner brackets */
.hero-corner {
  position: absolute;
  width: 24px;
  height: 24px;
  pointer-events: none;
  z-index: 1;
  opacity: 0.3;
}

.hero-corner::before,
.hero-corner::after {
  content: '';
  position: absolute;
  background-color: var(--vp-c-brand-1);
}

.hero-corner-tl {
  top: 24px;
  left: 24px;
}
.hero-corner-tl::before {
  top: 0;
  left: 0;
  width: 1px;
  height: 24px;
}
.hero-corner-tl::after {
  top: 0;
  left: 0;
  width: 24px;
  height: 1px;
}

.hero-corner-tr {
  top: 24px;
  right: 24px;
}
.hero-corner-tr::before {
  top: 0;
  right: 0;
  width: 1px;
  height: 24px;
}
.hero-corner-tr::after {
  top: 0;
  right: 0;
  width: 24px;
  height: 1px;
}

.hero-corner-bl {
  bottom: 24px;
  left: 24px;
}
.hero-corner-bl::before {
  bottom: 0;
  left: 0;
  width: 1px;
  height: 24px;
}
.hero-corner-bl::after {
  bottom: 0;
  left: 0;
  width: 24px;
  height: 1px;
}

.hero-corner-br {
  bottom: 24px;
  right: 24px;
}
.hero-corner-br::before {
  bottom: 0;
  right: 0;
  width: 1px;
  height: 24px;
}
.hero-corner-br::after {
  bottom: 0;
  right: 0;
  width: 24px;
  height: 1px;
}

/* Floating accent elements */
.hero-accent {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
  filter: blur(40px);
}

.hero-accent-1 {
  width: 120px;
  height: 120px;
  top: 10%;
  left: -5%;
  background: radial-gradient(circle, rgba(139, 92, 246, 0.12), transparent 70%);
}

.hero-accent-2 {
  width: 80px;
  height: 80px;
  bottom: 15%;
  right: 5%;
  background: radial-gradient(circle, rgba(167, 139, 250, 0.1), transparent 70%);
}

.hero-accent-3 {
  width: 60px;
  height: 60px;
  top: 60%;
  left: 40%;
  background: radial-gradient(circle, rgba(139, 92, 246, 0.08), transparent 70%);
}

.hero-content {
  position: relative;
  z-index: 1;
  animation: fadeIn 200ms ease-out both;
}

.hero-title {
  font-family: Inter, -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 48px;
  font-weight: 700;
  line-height: 1.2;
  letter-spacing: -0.02em;
  color: var(--vp-c-text-1);
  margin: 0 0 16px;
}

.gradient-text {
  background: linear-gradient(135deg, var(--vp-c-brand-1), var(--vp-c-brand-3, #a78bfa));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: 16px;
  font-weight: 400;
  line-height: 1.6;
  color: var(--vp-c-text-2);
  max-width: 48ch;
  margin: 0 0 32px;
}

.hero-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.btn {
  display: inline-block;
  font-family: Inter, -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 13px;
  font-weight: 500;
  line-height: 1;
  padding: 12px 24px;
  border-radius: 9999px;
  text-decoration: none;
  transition: all 200ms ease-out;
  cursor: pointer;
}

.btn-primary {
  background: linear-gradient(135deg, var(--vp-c-brand-2, #7c3aed), var(--vp-c-brand-1));
  color: #ffffff;
  border: none;
}

.btn-primary:hover {
  box-shadow: 0 0 16px rgba(139, 92, 246, 0.4);
  transform: translateY(-1px);
}

.btn-secondary {
  background: transparent;
  color: var(--vp-c-brand-3, #a78bfa);
  border: 1px solid var(--vp-c-brand-1);
}

.btn-secondary:hover {
  background-color: rgba(139, 92, 246, 0.1);
  border-color: var(--vp-c-brand-3, #a78bfa);
}

/* ============ CODE EDITOR ============ */
.hero-code {
  position: relative;
  z-index: 1;
  background-color: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border, #2e2e2e);
  border-radius: 6px;
  overflow: hidden;
  animation: fadeIn 200ms ease-out 60ms both;
}

.code-titlebar {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 14px;
  background-color: var(--vp-c-bg-alt, #242424);
  border-bottom: 1px solid var(--vp-c-border, #2e2e2e);
}

.code-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: var(--vp-c-border, #2e2e2e);
}

.code-dot:nth-child(1) { background-color: #ff5f56; }
.code-dot:nth-child(2) { background-color: #ffbd2e; }
.code-dot:nth-child(3) { background-color: #27c93f; }

.code-filename {
  margin-left: 8px;
  font-family: 'JetBrains Mono', 'Fira Code', ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 11px;
  color: var(--vp-c-text-2);
  letter-spacing: 0.02em;
}

.code-body-wrapper {
  position: relative;
  display: flex;
}

.code-gutter {
  display: flex;
  flex-direction: column;
  padding: 16px 12px 16px 14px;
  border-right: 1px solid var(--vp-c-border, #2e2e2e);
  background-color: rgba(0, 0, 0, 0.15);
  user-select: none;
}

.code-gutter span {
  font-family: 'JetBrains Mono', 'Fira Code', ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 13px;
  line-height: 1.7;
  color: var(--vp-c-text-2);
  opacity: 0.5;
  text-align: right;
  min-width: 12px;
}

.code-body {
  margin: 0;
  padding: 16px 18px;
  font-family: 'JetBrains Mono', 'Fira Code', ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 13px;
  line-height: 1.7;
  color: var(--vp-c-text-1);
  overflow-x: auto;
  flex: 1;
}

.code-body code {
  font-family: inherit;
}

.code-fade {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 32px;
  background: linear-gradient(to top, var(--vp-c-bg-soft), transparent);
  pointer-events: none;
}

.code-comment { color: var(--vp-c-text-2); font-style: italic; }
.code-keyword { color: var(--vp-c-brand-3, #a78bfa); }
.code-fn { color: var(--vp-c-brand-1); }

/* ============ SECTION DIVIDER ============ */
.section-divider {
  max-width: 960px;
  margin: 0 auto;
  padding: 0 32px;
  height: 1px;
  position: relative;
}

.section-divider::before {
  content: '';
  position: absolute;
  left: 32px;
  right: 32px;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--vp-c-brand-1), transparent);
  opacity: 0.3;
}

/* ============ CONCEPTS ============ */
.concepts {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  padding: 48px 32px 64px;
  max-width: 960px;
  margin: 0 auto;
}

.card {
  position: relative;
  background-color: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border, #2e2e2e);
  padding: 32px;
  transition: all 200ms ease-out;
  border-radius: 4px;
  overflow: hidden;
}

.card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 4px;
  padding: 1px;
  background: linear-gradient(135deg, var(--vp-c-brand-1), var(--vp-c-brand-3, #a78bfa), var(--vp-c-brand-1));
  background-size: 200% 200%;
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  opacity: 0;
  transition: opacity 300ms ease-out;
}

.card:hover::before {
  opacity: 1;
  animation: gradientShift 3s ease infinite;
}

.card:hover {
  border-color: transparent;
  box-shadow: 0 0 20px rgba(139, 92, 246, 0.25);
  transform: translateY(-2px);
}

.card-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(139, 92, 246, 0.1);
  border-radius: 8px;
  margin-bottom: 20px;
  transition: transform 200ms ease-out;
}

.card:hover .card-icon {
  transform: scale(1.1);
}

.card-icon svg {
  width: 32px;
  height: 32px;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  line-height: 1.5;
  color: var(--vp-c-text-1);
  margin: 0 0 8px;
}

.card-body {
  font-size: 14px;
  font-weight: 400;
  line-height: 1.6;
  color: var(--vp-c-text-2);
  margin: 0;
}

/* ============ MANIFESTO ============ */
.manifesto {
  background-color: var(--vp-c-bg-alt, #242424);
  border-top: 1px solid var(--vp-c-border, #2e2e2e);
  border-bottom: 1px solid var(--vp-c-border, #2e2e2e);
  padding: 64px 32px;
  position: relative;
}

.manifesto::before,
.manifesto::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--vp-c-brand-1), transparent);
  opacity: 0.35;
}

.manifesto::before { top: -1px; }
.manifesto::after { bottom: -1px; }

.manifesto-line {
  font-family: Inter, -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 20px;
  font-weight: 500;
  font-style: italic;
  line-height: 1.5;
  color: var(--vp-c-text-1);
  max-width: 65ch;
  margin: 0 auto;
  text-align: center;
  position: relative;
}

.manifesto-line::before {
  content: '\201C';
  position: absolute;
  left: -40px;
  top: -20px;
  font-size: 80px;
  font-family: Georgia, serif;
  color: var(--vp-c-brand-1);
  opacity: 0.15;
  line-height: 1;
}

.manifesto-line::after {
  content: '\201D';
  position: absolute;
  right: -40px;
  bottom: -40px;
  font-size: 80px;
  font-family: Georgia, serif;
  color: var(--vp-c-brand-1);
  opacity: 0.15;
  line-height: 1;
}

/* ============ FOOTER ============ */
.strip {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 32px;
  background-color: var(--vp-c-bg);
  border-top: 1px solid var(--vp-c-border, #2e2e2e);
  position: relative;
}

.strip-glow {
  position: absolute;
  top: -1px;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--vp-c-brand-1), transparent);
  filter: blur(4px);
  opacity: 0.5;
  pointer-events: none;
}

.strip-license {
  font-size: 12px;
  font-weight: 500;
  color: var(--vp-c-text-2);
}

.strip-link {
  font-size: 12px;
  font-weight: 500;
  color: var(--vp-c-brand-3, #a78bfa);
  text-decoration: none;
  transition: color 200ms ease-out;
}

.strip-link:hover {
  color: var(--vp-c-brand-1);
}

/* ============ ANIMATIONS ============ */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(12px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes gradientShift {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

/* ============ RESPONSIVE ============ */
@media (max-width: 767px) {
  .hero {
    grid-template-columns: 1fr;
    padding: 48px 16px;
    gap: 32px;
  }

  .hero-title {
    font-size: 36px;
  }

  .hero-subtitle {
    font-size: 15px;
  }

  .hero-corner {
    display: none;
  }

  .hero-accent {
    display: none;
  }

  .concepts {
    grid-template-columns: 1fr;
    padding: 0 16px 48px;
    gap: 16px;
  }

  .card {
    padding: 24px;
  }

  .manifesto {
    padding: 48px 16px;
  }

  .manifesto-line {
    font-size: 18px;
  }

  .manifesto-line::before {
    left: -20px;
    top: -10px;
    font-size: 60px;
  }

  .manifesto-line::after {
    right: -20px;
    bottom: -30px;
    font-size: 60px;
  }

  .strip {
    padding: 16px;
    flex-direction: column;
    gap: 8px;
    text-align: center;
  }

  .section-divider {
    padding: 0 16px;
  }

  .section-divider::before {
    left: 16px;
    right: 16px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .hero-content,
  .hero-code,
  .card,
  .btn,
  .strip-link {
    animation: none;
    transition: none;
  }

  .btn-primary:hover {
    transform: none;
  }

  .card:hover {
    transform: none;
  }

  .card:hover .card-icon {
    transform: none;
  }

  .card:hover::before {
    animation: none;
  }
}
</style>
