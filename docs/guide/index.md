---
title: Introduction
description: What the RBX DDD architecture is, why use it, and how the server/client bootstrappers initialize a Roblox Luau project.
---

# Introduction

Welcome to RBX DDD Architecture. If you've ever worked on a Roblox project that grew from a few scripts into a tangled mess of dependencies, you know the pain. We've all been there: you start with a simple game, add a few modules, and suddenly everything depends on everything else. Circular dependencies creep in, startup order becomes a guessing game, and adding a new feature feels like defusing a bomb. This architecture solves that problem by applying Domain-Driven Design principles to the Roblox instance tree.

Think of it as a folder-and-convention foundation where every module has a fixed home, a fixed lifecycle, and a fixed contract. You add files in the right folder and they just work—no manual wiring between modules, no "where do I put this?" moments, no circular dependency headaches. The reason this works is that we've made the important decisions for you: where things go, how they load, and how they communicate. You focus on gameplay; the architecture handles the plumbing.

One script generates the entire tree, the server and client bootstrappers, and the contract scaffolding. From there, the structure scales from 3 services to 30 without refactoring. You'll notice that as your project grows, the architecture doesn't get in your way—it gets out of it. That's the whole point: conventions that scale, so you don't have to rewrite your foundation every time you add a new system.

## Why use it

Let's be honest: you could build a Roblox game without any architecture. For a small prototype, a handful of scripts in ServerScriptService works fine. But once your team grows past one person or your game needs more than a dozen systems, the cracks start showing fast. Here's why teams choose this approach instead of winging it:

| Benefit | Detail |
|---|---|
| Instant setup | One script builds the entire folder tree, bootstrappers, and contracts. Zero manual configuration. |
| Convention over configuration | Services load themselves. Controllers register `start()`. No manual wiring between modules. |
| Synchronized server-client | Client waits for `ServerLoaded` before initializing. No race conditions at startup. |
| Scale without refactoring | Start with 3 services, grow to 30 without changing the structure. Add a module in the right folder, it is ready. |
| Native observability | LogService integrated. Every load/failure appears in the Studio Output with clear context. |
| Explicit contract | Typed interfaces (`Controller`, service return). Contract errors fail at load time, not silent runtime. |

The reason we emphasize convention over configuration is simple: when everyone on the team knows where things go and how they behave, you spend less time reading code and more time writing it. The bootstrapper handles the plumbing so you can focus on gameplay. And because the conventions are enforced by structure rather than documentation, new team members get productive quickly—they just follow the folder layout and the system does the rest.

## Initialization flow

One of the most common sources of bugs in Roblox games is startup ordering. You've probably seen it: a LocalScript tries to call a RemoteEvent before the server has set it up, or a client controller assumes a service is ready when it's still loading. Here's what happens when you hit Play in Studio, and how the architecture prevents those issues:

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

You might wonder why we don't let the client start immediately. The answer is race conditions. If the client tries to call a service that hasn't loaded yet, you get nil references and silent failures. By making the client wait for an explicit signal, we guarantee that the server-side infrastructure is ready before any client code runs. Think of it as a handshake: the server says "I'm ready," and only then does the client begin its own initialization. This simple pattern eliminates an entire class of timing bugs that plague most Roblox projects.

## Where to go next

Now that you understand the philosophy and the flow, let's talk about the practical next steps. Every folder in this architecture has an exact meaning and a specific role. Before you place your first module, take a few minutes to read the [folder reference](/architecture/folder-reference)—it'll save you from moving files around later and help you internalize where things belong.

Once you understand the structure, head over to [installation](/guide/installation) to get the architecture into your place. The installation process is straightforward: one script, a few seconds, and you're ready to start building.

The goal here isn't to add bureaucracy or slow you down. It's to give you a foundation that stays out of your way as your game grows. When you follow the conventions, the architecture becomes invisible—you just write code, and it works. That's the kind of foundation that lets you focus on what matters: making your game great. Let's get started.
