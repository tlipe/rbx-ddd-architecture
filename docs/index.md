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
  - icon: 🖥️
    title: Server-Authoritative
    details: All state lives on the server. Clients render; they never own truth.
  - icon: 📄
    title: Typed Contracts
    details: Luau types define every module boundary. No untyped Remote traffic.
  - icon: ⚡
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
