# Design Spec: Premium VitePress Homepage

## Design Read
Landing page for developer tool (Roblox Luau DDD architecture), technical audience, dark-tech aesthetic with graphite + violet + amber palette. Leaning toward Linear-style minimalism with premium developer tool details.

## Critical Technical Constraint
Must use `layout: home` in frontmatter. All custom content inline in index.md (HTML + scoped CSS). Cannot import external Vue components.

## Hero Section
**Layout:** Asymmetric 60/40 split (content left, code preview right)
**Background:** 
- Dot grid pattern (radial-gradient, 24px spacing, opacity 0.04)
- Radial glow (violet, 60% width, 50% height, opacity 0.08)
- Corner brackets (4x, 24px L-shapes, violet, opacity 0.3)
- 3 floating accent circles (blurred, opacity 0.08-0.12)

**Content (left 60%):**
- Version badge: pill shape, violet border, green status dot + "v1.0 Stable"
- Title: 48px, "RBX DDD Architecture" with "DDD" in violet gradient
- Subtitle: 16px, text-2 color, max-width 48ch
- Buttons: primary (violet gradient pill, glow hover), secondary (outlined violet pill)

**Code Preview (right 40%):**
- macOS-style window: titlebar with 3 dots (red/yellow/green), filename
- Line numbers gutter (1-10, subtle border)
- Syntax highlighting: keywords violet, functions violet-light, comments text-2
- Fade overlay at bottom (gradient to bg)

## Concepts Section
**Layout:** Asymmetric bento grid (2fr + 1fr + 1fr), NOT 3 equal columns
**Cards:**
- Background: bg-soft
- Border: 1px border, animated gradient border on hover (violet)
- Padding: 32px
- Icon: 48x48 container, violet tint bg, 8px radius, scale 1.1 on card hover
- Title: 16px semibold
- Body: 14px text-2, max-width 48ch
- Hover: lift -2px, violet glow shadow

**Card 1 (wide, 2fr):** Server-Authoritative - icon: server rack
**Card 2 (1fr):** Typed Contracts - icon: document with lines
**Card 3 (1fr):** Hot-Reload Ready - icon: lightning bolt

## Section Divider
Gradient line: transparent → violet → transparent, opacity 0.3, height 1px

## Manifesto Section
**Background:** bg-alt
**Borders:** top/bottom gradient glow (violet, opacity 0.35)
**Quote:** 20px italic, centered, max-width 65ch
**Decorative quotes:** ::before/::after with " (80px, opacity 0.15, violet)

## Footer
**Layout:** Flex, space-between
**Top border:** gradient glow (violet, blur 4px)
**Left:** "MPL-2.0 License" (12px, text-2)
**Right:** GitHub link (12px, violet-light, hover violet)

## Color Tokens
- bg: #1a1a1a
- bg-alt: #242424
- bg-soft: #1e1e1e
- text-1: #e5e5e5
- text-2: #a3a3a3
- brand-1: #8b5cf6 (violet)
- brand-2: #7c3aed (violet dark)
- brand-3: #a78bfa (violet light)
- border: #2e2e2e
- warning: #f59e0b (amber)

## Spacing
- Hero padding: 80px top, 64px bottom
- Section padding: 64px vertical
- Card padding: 32px
- Max-width: 960px
- Gap: 24px (cards), 48px (hero columns)

## Responsive
- Mobile (<767px): stack hero vertically, single-column cards
- Hide decorative elements on mobile (corners, floating accents)
- Reduce quote mark size

## Reduced Motion
- Disable all animations
- Remove hover transforms
- Remove gradient border animation

## Implementation
All HTML/CSS inline in index.md using scoped `<style>` block. No external Vue components.
