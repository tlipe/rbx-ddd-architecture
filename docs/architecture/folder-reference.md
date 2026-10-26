---
title: Folder Reference
description: "Exact meaning of every folder in the RBX DDD architecture tree: workspace, shared, server, and client."
---

# Folder Reference

One of the first questions you'll have when working with this architecture is: "Where does this module belong?" That's exactly what this reference answers. Every folder has one fixed purpose, and once you understand what each one does, placing modules becomes second nature.

You'll notice that the architecture is organized around a simple principle: separation of concerns by execution context. Server code lives in one place, client code in another, and shared code bridges the gap. This isn't just about keeping things tidy—it's about making it impossible to accidentally mix server-only logic with client code, which is one of the most common sources of bugs in Roblox development.

The tree below is what the installer generates. Place a module in the right folder and its lifecycle is handled by the bootstrapper—you don't need to manually wire anything.

```
workspace/
├── Client/
└── Server/

ReplicatedStorage/
└── shared/
    ├── definitions/
    ├── events/
    ├── index/
    ├── registry/
    ├── packages/
    └── utils/

ServerScriptService/
└── server/
    ├── bootstrapper          (Script)
    ├── classes/
    ├── controllers/
    ├── services/
    └── utils/

StarterPlayer/StarterPlayerScripts/
└── client/
    ├── bootstrapper          (LocalScript)
    ├── classes/
    ├── entities/
    ├── controllers/
    ├── services/
    ├── ui/
    │   ├── frames/
    │   ├── helpers/
    │   └── hud               (ModuleScript)
    └── utils/
```

## workspace

The `workspace` folder is split into two subfolders that separate client-only visuals from server-authoritative objects. This separation matters because it makes it immediately clear which instances are replicated to all players and which are local-only.

Think of it this way: when you're debugging a replication issue at 2 AM, you don't want to guess whether an object should be visible to everyone or just the local player. This folder structure gives you that answer instantly.

### workspace/Client

This folder holds all client-side rendered instances. Think physical objects, visual effects, anything visible only to the local player. If it's a client-only visual representation—like a local particle effect or a temporary marker—it goes here.

The reason we separate these from server instances is clarity. When you're debugging replication issues, you can immediately see which objects are local-only versus which should be visible to everyone. It's the difference between guessing and knowing.

### workspace/Server

This folder holds all server-authoritative instances. These are visible to every player. Replicated physical objects, world effects, shared visuals—anything that needs to be consistent across all clients lives here.

When you create an instance in `Workspace/Server`, you're making a statement: "This is the source of truth, and all clients should see it." This is where your game's persistent state lives—the things that need to be synchronized across all players.

## shared (ReplicatedStorage)

The `shared` folder is where server and client meet. Everything here is replicated to both sides, which means it needs to be safe for both contexts. You'll notice that shared modules are typically pure data, network definitions, or utility functions that work identically on both sides.

This is the bridge between your server and client. The key insight is that anything in this folder can be required from either side, so it must not have side effects that only make sense in one context. Think of it as a contract zone—both sides agree on what's here.

### shared/definitions

This is where you define schemas, contracts, types, enums, and constants. Think of it as the data shape agreements used across server and client. When you need both sides to agree on what a "PlayerData" object looks like, that definition lives here.

The benefit of centralizing these is that you can't accidentally drift out of sync. If the server expects a `coins` field and the client expects a `gold` field, you'll catch it at the definition level, not in a runtime error. It's like having a single source of truth for your data contracts.

### shared/events

All server-client connections live here. This includes RemoteEvents, RemoteFunctions, and network library wrappers. The convention is one ModuleScript per connection, named after the event (e.g., `purchaseItem.luau`). Inside, you'll find code that fires or listens on that connection. The pattern always ends with `return 0`.

The reason we use one file per event is maintainability. When you're debugging a network issue, you can immediately find the exact file that handles that connection. No hunting through monolithic network modules. It's the difference between finding a needle in a haystack and knowing exactly which drawer it's in.

### shared/index

This folder holds pure data tables. Direct `return { ... }`. No methods attached. Query, filter, and lookup helpers belong in `shared/utils/*Helper`. Indexes are data, not APIs.

You might wonder why we don't attach methods to the data tables. The answer is separation of concerns. Data should be pure and immutable. Behavior should be in utilities. This makes the data easy to reason about and the utilities easy to test. When you open an index file, you see exactly what data is available—no hidden behavior lurking in methods.

### shared/registry

Think of this as a registrar or voter environment. Modules here record or annotate state, votes, registrations. The pattern is a single expression: `return { key = value, ... }`. Never assign to a local first. Never use `table.freeze()`.

The reason for the strict single-expression rule is that it makes the data shape immediately visible. When you open a registry file, you see the entire dataset in one return statement. No hunting through the file to piece together what's being registered. It's like looking at a table of contents instead of reading the entire book to understand its structure.

### shared/packages

This folder is for ALL external libraries described as libraries. User-added packages like Warp, KoltStore, Spring. Nothing else lives here.

The reason we keep this folder pure is dependency management. When you need to update or audit third-party code, you know exactly where to look. Mixing project-specific modules with external libraries makes it hard to tell what's yours and what's maintained upstream. Think of it as your "vendor" folder—everything here came from somewhere else.

### shared/utils

Helper and utility ModuleScripts shared by BOTH sides go here. These are pure functions reusable from server and client. Side-effect free and deterministic.

If a function needs to work identically on both sides and doesn't touch the network or game state, it belongs here. Think math helpers, formatting functions, data transformations. The key test is: "Would this function work the same way if I called it from the server or the client?" If yes, it goes here.

## server (ServerScriptService)

The `server` folder is where your server-side logic lives. This is the authoritative side—the one that validates, persists, and orchestrates gameplay systems.

Everything here runs only on the server. This is where you put code that handles game state, data persistence, validation, and orchestration. If it's logic that players shouldn't be able to see or tamper with, it belongs here.

### server/bootstrapper

This is the Script entry point. It loads services, then controllers, calls `start()` on each, and sets `workspace.ServerLoaded`. You'll rarely need to modify this—it's the engine that makes the architecture work.

Think of the bootstrapper as the conductor of an orchestra. It doesn't play any instruments itself, but it makes sure everyone starts at the right time and in the right order. You built the instruments (your services and controllers); the bootstrapper makes them play together.

### server/classes

Stateful domain objects live here. Classes and enums dedicated to specific game objects. If you have a `PlayerCharacter` class with methods and state, it goes here.

This is where you model your game's domain. Think of it as your object-oriented layer—the place where you define the entities that populate your game world. A `Weapon` class, a `PlayerCharacter` class, a `Quest` class—these all belong here.

### server/controllers

Controllers orchestrate systems. They have a lifecycle hook: `function controllerName:start()`. This is where you wire up gameplay systems, connect signals, and drive the flow of your game.

The reason controllers have a `start()` method but services don't is that controllers need to initialize in a specific order, after all services are ready. Services initialize at require time; controllers initialize when explicitly started. Think of services as the foundation and controllers as the rooms built on top of it—you can't build the rooms until the foundation is poured.

### server/services

Long-lived infrastructure goes here. Services are initialized once when required. They return either a table of public methods or `return 0` if they're side-effect only. No `start()` method.

Think of services as the foundation: data persistence, authentication, resource management. They're always available, always initialized, and they don't need a startup sequence. When you need a piece of infrastructure that other modules will depend on, you build it as a service.

### server/utils

Helpers dedicated to the SERVER side and its neighbor folders (classes, controllers, services). If a utility only makes sense in a server context, it belongs here rather than in `shared/utils`.

The distinction is simple: if the function touches server-only APIs or only makes sense when running on the server, it goes here. If it could work on both sides, it belongs in `shared/utils`.

## client (StarterPlayerScripts)

The `client` folder mirrors the server structure but handles everything that runs on the player's machine. Input, rendering, UI, camera control—this is where the player experience comes to life.

This is where you build the player's direct experience. Everything here runs only on the client, which means you have access to user input, camera control, and rendering APIs that don't exist on the server.

### client/bootstrapper

This is the LocalScript entry point. It waits for `ServerLoaded`, loads services, controllers, HUD, and sets `workspace.ClientLoaded`. Like the server bootstrapper, you'll rarely need to touch this.

The client bootstrapper plays a waiting game—it holds off on loading until the server signals that it's ready. This ensures that when your client code starts running, the server-side infrastructure is already in place.

### client/classes

Classes and enums scoped to the client. Same purpose as `server/classes` but client-side. If you have a `CameraController` class or client-specific data structures, they go here.

Just like the server has its domain objects, the client has its own. A `CameraRig` class, a `UIAnimation` class, a `InputHandler` class—these are client-specific domain objects.

### client/entities

ModuleScripts acting 100% on in-game entities renderable on the client. These need a server-client connection strategy. This is where you handle optimization and rendering of entities, including players.

The reason we have a separate `entities` folder on the client (but not the server) is that client-side entity management is complex enough to warrant its own space. You're dealing with interpolation, prediction, visual smoothing—concepts that don't apply server-side. Think of it as your rendering optimization layer.

### client/controllers

Input handlers, camera control, animations. These use `start()` just like server controllers. The difference is what they orchestrate: client controllers handle the player's direct experience.

Where server controllers orchestrate game systems, client controllers orchestrate the player's sensory experience. They handle what the player sees, hears, and interacts with directly.

### client/services

AudioService/TweenService wrappers and similar client-side infrastructure. They return `0` or a table of methods, just like server services.

These are your client-side foundations. An `AudioService` wrapper, a `TweenService` wrapper, a `UIManager`—these provide infrastructure that other client modules depend on.

### client/ui/frames

One ModuleScript per UI surface. The module name IS the UI it programs (`shopCoin.luau`, `shopSwords.luau`, `inventoryFrame.luau`). Inside, you'll find normal code building that interface. It always ends with `return 0`.

The reason we use one file per UI surface is that it keeps each screen or component isolated. When you need to fix a bug in the shop UI, you open `shopCoin.luau` and you're done. No hunting through a massive UI module. It's the UI equivalent of one class per file—simple, direct, and easy to navigate.

### client/ui/helpers

Quick reusable helpers scoped to the frames folder. These are consumed by sibling frame modules. Think formatting functions, animation builders, layout utilities.

These are the utility functions that your UI frames share. If multiple frames need the same animation builder or formatting function, it lives here instead of being duplicated in each frame.

### client/ui/hud

This is a ModuleScript that orchestrates frames via `task.spawn`. It returns `0`. You'll rarely need to modify this—it's the engine that loads all your UI frames in parallel.

The HUD runner is like a stage manager—it makes sure all your UI frames load at the same time instead of one after another. This parallel loading is what makes your UI feel snappy instead of sluggish.

### client/utils

Helpers dedicated to the CLIENT side and its neighbor folders (classes, entities, controllers, services). If a utility only makes sense in a client context, it belongs here.

Same principle as `server/utils`: if it only works on the client, it goes here. If it could work on both sides, it belongs in `shared/utils`.

::: tip
If you are unsure where a module belongs, ask two questions: does it touch the network? then `shared/events`. Is it pure data? then `shared/index` or `shared/registry`. Everything else follows the lifecycle rules in [Contracts](/architecture/contracts).
:::

Now that you understand where everything goes, you're ready to start building. The next step is understanding the contracts each module type must follow—head over to [Contracts](/architecture/contracts) to see what the bootstrapper expects from each module.
