---
title: Introduction
description: What the RBX DDD architecture is, why use it, and how the server/client bootstrappers initialize a Roblox Luau project.
---

# Introduction

RBX DDD Architecture is a folder-and-convention foundation for Roblox Luau projects where every module has a fixed home, lifecycle, and contract. You add files in the right folder and they work — no manual wiring between modules.

One script generates the entire tree, the server and client bootstrappers, and the contract scaffolding. The structure scales from 3 services to 30 without refactoring.

## Why use it

| Benefit | Detail |
|---|---|
| Instant setup | One script builds the entire folder tree, bootstrappers, and contracts with zero manual configuration. |
| Convention over configuration | Services load themselves and controllers register `start()`, eliminating manual wiring between modules. |
| Synchronized server-client | Client waits for `ServerLoaded` before initializing, preventing race conditions at startup. |
| Scale without refactoring | Start with 3 services and grow to 30 without changing the structure — just add a module in the right folder and it is ready. |
| Native observability | LogService is integrated, so every load and failure appears in the Studio Output with clear context. |
| Explicit contract | Typed interfaces (`Controller`, service return) ensure contract errors fail at load time instead of causing silent runtime issues. |

## Initialization flow

```
Studio Play
    │
    ▼
server/bootstrapper (Script)
    ├── loads services/*.luau ──► require + count (initialized once, no start())
    ├── loads controllers/*.luau ──► require + validates start()
    ├── executes controller:start() in order
    └── workspace.ServerLoaded = true
            │
            ▼
client/bootstrapper (LocalScript)
    ├── awaits ServerLoaded (GetAttributeChangedSignal)
    ├── loads services/*.luau
    ├── loads controllers/*.luau
    ├── loads ui/hud
    └── workspace.ClientLoaded = true
```

The server finishes first and flips `workspace.ServerLoaded`. The client listens on that attribute and only then loads its own services, controllers, and HUD. Startup ordering is enforced by the bootstrappers, not by each module.

## Where to go next

- [Folder Reference](/architecture/folder-reference): exact meaning of every folder in the tree.
- [Installation](/guide/installation): get the architecture into your place.
- [Contracts](/architecture/contracts): what each module type must return.
