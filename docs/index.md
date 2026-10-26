---
layout: home

hero:
  name: "RBX DDD Architecture"
  text: "Domain-Driven Design for Roblox Studio"
  tagline: "Clean layers, typed boundaries, zero ceremony."
  actions:
    - theme: brand
      text: Get Started
      link: /guide/installation
    - theme: alt
      text: GitHub
      link: https://github.com/tlipe/rbx-ddd-architecture

features:
  - icon: <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#8b5cf6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"/><rect x="2" y="14" width="20" height="8" rx="2" ry="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>
    title: Server-Authoritative
    details: All state lives on the server. Clients render; they never own truth.
  - icon: <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#8b5cf6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
    title: Typed Contracts
    details: Luau types define every module boundary. No untyped Remote traffic.
  - icon: <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#8b5cf6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
    title: Hot-Reload Ready
    details: Registry wiring survives Studio reloads without manual teardown.
---

<style>
.VPHomeHero .main { max-width: 960px; }
.VPHomeHero .name { font-size: 48px; font-weight: 700; }
.VPHomeHero .text { font-size: 20px; }
.VPHomeHero .tagline { font-size: 16px; }
.VPHomeHero .actions .VPButton { font-size: 16px; padding: 16px 36px; }
.VPHomeFeatures { max-width: 960px; margin: 0 auto; padding: 48px 32px; }
.VPHomeFeatures .feature { padding: 32px; }
</style>
