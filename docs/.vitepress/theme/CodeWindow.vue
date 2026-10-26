<template>
  <div class="code-window">
    <div class="code-titlebar">
      <span class="code-dot code-dot-red"></span>
      <span class="code-dot code-dot-yellow"></span>
      <span class="code-dot code-dot-green"></span>
      <span class="code-filename">{{ filename }}</span>
    </div>
    <div class="code-body-wrapper">
      <div class="code-gutter">
        <span v-for="n in lineCount" :key="n">{{ n }}</span>
      </div>
      <div class="code-content">
        <slot></slot>
      </div>
      <div class="code-fade"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  filename: string
  lineCount: number
}>()
</script>

<style scoped>
.code-window {
  background-color: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border, #2e2e2e);
  border-radius: 6px;
  overflow: hidden;
  animation: fadeIn 200ms ease-out 180ms both;
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
}

.code-dot-red { background-color: #ff5f56; }
.code-dot-yellow { background-color: #ffbd2e; }
.code-dot-green { background-color: #27c93f; }

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

.code-content {
  padding: 16px 18px;
  font-family: 'JetBrains Mono', 'Fira Code', ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 13px;
  line-height: 1.7;
  color: var(--vp-c-text-1);
  overflow-x: auto;
  flex: 1;
  white-space: pre;
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

@media (prefers-reduced-motion: reduce) {
  .code-window {
    animation: none;
  }
}
</style>
