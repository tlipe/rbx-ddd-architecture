---
title: Folder Reference
description: "Exact meaning of every folder in the RBX DDD architecture tree: workspace, shared, server, and client."
---

# Folder Reference

Every folder has one fixed purpose. Place a module in the right folder and its lifecycle is handled by the bootstrapper. The structure separates code by execution context and responsibility, making it impossible to accidentally mix server-only logic with client code.

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

The workspace folder is split into two subfolders that separate client-only visuals from server-authoritative objects. This separation exists because Roblox replicates everything in workspace to all clients by default. When you need an object visible only to the local player (like a selection highlight or local particle effect), it goes in `workspace/Client`. When you need an object visible to everyone (like a physical prop or world effect), it goes in `workspace/Server`.

### workspace/Client

Holds client-side rendered instances. Physical objects, visual effects, anything visible only to the local player. Examples: local particle effects, temporary markers, selection highlights, client-only decorations.

The bootstrapper does not manage this folder. You create and destroy instances here directly from client code. The folder exists purely as a visual organizer in the Explorer.

### workspace/Server

Holds server-authoritative instances. Visible to every player. Replicated physical objects, world effects, shared visuals. Examples: physical props, environmental effects, shared markers, world-state objects.

Like `workspace/Client`, the bootstrapper does not manage this folder. You create and destroy instances here directly from server code. The separation from `workspace/Client` makes it immediately clear which objects are replicated and which are local-only.

## shared (ReplicatedStorage)

The shared folder is where server and client meet. Everything here is replicated to both sides, which means modules must be safe for both contexts. This is the contract zone: both sides agree on what's here, and nothing in this folder can have side effects that only make sense in one context.

Shared modules are typically pure data, network definitions, or utility functions that work identically on both sides. If a module touches the network, it goes in `shared/events`. If it's pure data, it goes in `shared/index` or `shared/registry`. If it's a reusable function with no side effects, it goes in `shared/utils`.

### shared/definitions

Schemas, contracts, types, enums, constants. Data shape agreements used across server and client.

When both sides need to agree on what a data structure looks like (like a `PlayerData` table with `coins` and `level` fields), that definition lives here. Centralizing these prevents drift: if the server expects `coins` and the client expects `gold`, you catch it at the definition level instead of in a runtime error.

### shared/events

Server-client connections. RemoteEvents, RemoteFunctions, network library wrappers. One ModuleScript per connection, named after the event (e.g., `purchaseItem.luau`). The module wraps the network library call and ends with `return 0`.

The one-file-per-event rule exists for maintainability. When you're debugging a network issue, you open `purchaseItem.luau` and see exactly how that connection works in five lines. You don't hunt through a monolithic network module with 400 lines of `if eventName == "purchaseItem" then ... elseif ...` chains. The filename is the event name, and the file contains only the wiring for that one connection.

Both sides require the same module path so the channel definition stays identical on server and client. If you defined the channel separately on each side, you could accidentally drift out of sync: different parameter names, different types, silent failures.

### shared/index

Pure data tables. Direct `return { ... }`. No methods attached. Query, filter, and lookup helpers belong in `shared/utils/*Helper`.

Indexes hold catalog-style data: item lists, config tables, static mappings. The data is immutable and method-free. When you open an index file, you see exactly what data is available. No hidden behavior lurking in methods. The separation between data and behavior makes both easier to understand and test.

### shared/registry

Registrar or voter environment. Modules record or annotate state, votes, registrations. Single expression: `return { key = value, ... }`. Never assign to a local first. Never use `table.freeze()`.

Registries hold dynamic registrations: who registered what, tally state, annotated runtime data. The single-expression rule exists because it makes the data shape immediately visible. When you open a registry file, you see the entire dataset in one return statement. No hunting through the file to piece together what's being registered.

The distinction between `shared/index` and `shared/registry` is semantic, not mechanical. Both use direct `return { ... }`. Both attach no methods. Both never freeze. Indexes are for static catalogs that don't change at runtime. Registries are for dynamic registrations that get added or modified as the game runs.

### shared/packages

External libraries only. User-added packages like Warp, KoltStore, Spring. Nothing project-specific belongs here.

This folder is your vendor directory. Everything here came from somewhere else. When you need to update or audit third-party code, you know exactly where to look. Mixing project-specific modules with external libraries makes it hard to tell what's yours and what's maintained upstream.

### shared/utils

Helper and utility ModuleScripts shared by both sides. Pure functions reusable from server and client. Side-effect free and deterministic.

If a function needs to work identically on both sides and doesn't touch the network or game state, it belongs here. Math helpers, formatting functions, data transformations. The test is simple: would this function work the same way if you called it from the server or the client? If yes, it goes here. If no, it belongs in `server/utils` or `client/utils`.

## server (ServerScriptService)

The server folder is where your server-side logic lives. This is the authoritative side: the one that validates, persists, and orchestrates gameplay systems. Everything here runs only on the server. This is where you put code that handles game state, data persistence, validation, and orchestration. If it's logic that players shouldn't be able to see or tamper with, it belongs here.

### server/bootstrapper

Script entry point. Loads services, then controllers, calls `start()` on each, sets `workspace.ServerLoaded`. Rarely needs modification.

The bootstrapper is the engine that makes the architecture work. It loads services first (they initialize at require time), then loads controllers and calls `start()` in order. Once everything is ready, it flips `workspace.ServerLoaded` to signal the client. You built the instruments (your services and controllers); the bootstrapper makes them play together.

### server/classes

Stateful domain objects. Classes and enums dedicated to specific game objects. If you have a `PlayerCharacter` class with methods and state, it goes here.

This is where you model your game's domain. A `Weapon` class, a `PlayerCharacter` class, a `Quest` class. These are the entities that populate your game world. Classes hold state and behavior together. They're distinct from services (which are infrastructure) and controllers (which orchestrate).

### server/controllers

Orchestrate systems. Lifecycle hook: `function controllerName:start()`. Wire up gameplay systems, connect signals, drive the flow.

Controllers have a `start()` method because they need to initialize in a specific order, after all services are ready. If a controller tried to use a service before that service was initialized, you'd get nil references. The `start()` method ensures proper sequencing. Services initialize at require time; controllers initialize when explicitly started. Services are the foundation; controllers are the rooms built on top of it.

Controllers don't hold domain logic. They connect the dots between services, classes, and events. A `GameController` orchestrates the game loop. A `CombatController` manages combat flow. A `PlayerJoinController` handles player join and leave. Each controller owns one system and wires it into the rest of the architecture.

### server/services

Long-lived infrastructure. Initialized once when required. Return either a table of public methods or `return 0` if side-effect only. No `start()` method.

Services are your application's infrastructure layer. A `DataStoreService` that handles persistence. An `AuthService` that manages authentication. A `ResourceService` that manages game assets. These are always-on systems that other modules depend on. They're like the plumbing in your house: always there, always working, and you don't need to turn them on every morning.

A failing require kills that service only; the rest continue loading. This is intentional. One broken service shouldn't take down your entire game. You'll see a `[SERVICE]` error in the Output, and you can fix it without affecting other systems.

### server/utils

Helpers dedicated to the server side and its neighbor folders (classes, controllers, services). If a utility only makes sense in a server context, it belongs here rather than in `shared/utils`.

The distinction is simple: if the function touches server-only APIs or only makes sense when running on the server, it goes here. If it could work on both sides, it belongs in `shared/utils`.

## client (StarterPlayerScripts)

The client folder mirrors the server structure but handles everything that runs on the player's machine. Input, rendering, UI, camera control. This is where the player's direct experience comes to life. Everything here runs only on the client, which means you have access to user input, camera control, and rendering APIs that don't exist on the server.

### client/bootstrapper

LocalScript entry point. Waits for `ServerLoaded`, loads services, controllers, HUD, sets `workspace.ClientLoaded`. Rarely needs modification.

The client bootstrapper plays a waiting game. It holds off on loading until the server signals that it's ready. This ensures that when your client code starts running, the server-side infrastructure is already in place. Without this handshake, you'd get race conditions: client code trying to call a service that hasn't loaded yet, or a controller assuming a service is ready when it's still initializing.

### client/classes

Classes and enums scoped to the client. Same purpose as `server/classes` but client-side. If you have a `CameraController` class or client-specific data structures, they go here.

Just like the server has its domain objects, the client has its own. A `CameraRig` class, a `UIAnimation` class, an `InputHandler` class. These are client-specific domain objects that don't exist on the server.

### client/entities

ModuleScripts acting on in-game entities renderable on the client. Need a server-client connection strategy. Handle optimization and rendering of entities, including players.

Client-side entity management is complex enough to warrant its own space. You're dealing with interpolation, prediction, visual smoothing. Concepts that don't apply server-side. This is your rendering optimization layer. Entities are the visual representations of game objects on the client, and this folder handles how they're rendered, updated, and synchronized with server state.

### client/controllers

Input handlers, camera control, animations. Use `start()` like server controllers. Orchestrate the player's direct experience.

Where server controllers orchestrate game systems, client controllers orchestrate the player's sensory experience. They handle what the player sees, hears, and interacts with directly. A `CameraController` manages camera behavior. An `InputController` handles user input. An `AnimationController` drives character animations. Same lifecycle as server controllers, different domain.

### client/services

AudioService/TweenService wrappers and similar client-side infrastructure. Return `0` or a table of methods, like server services.

These are your client-side foundations. An `AudioService` wrapper, a `TweenService` wrapper, a `UIManager`. They provide infrastructure that other client modules depend on. Same pattern as server services: initialize once at require time, expose public methods or return `0` if side-effect only.

### client/ui/frames

One ModuleScript per UI surface. The module name is the UI it programs (`shopCoin.luau`, `shopSwords.luau`, `inventoryFrame.luau`). Normal code building that interface. Always ends with `return 0`.

The one-file-per-UI-surface rule exists because it keeps each screen or component isolated. When you need to fix a bug in the shop UI, you open `shopCoin.luau` and you're done. You don't hunt through a massive UI module with 600 lines of GUI construction, signal wiring, and state management. Each frame is independent, easy to understand, and easy to debug.

Frames are presentation layers. They read state, display it, and forward user input through events. All computation happens on the server. Frames never require each other. Shared state flows through attributes or events, not direct module coupling. This keeps each frame independent and prevents tangled dependencies.

### client/ui/helpers

Reusable helpers scoped to the frames folder. Consumed by sibling frame modules. Formatting functions, animation builders, layout utilities.

If you find yourself copying the same formatting code across multiple frames, extract it into a helper. This keeps your frames DRY and makes the formatting logic easier to test and maintain. Helpers are pure builders and formatters, not state holders.

### client/ui/hud

ModuleScript that orchestrates frames via `task.spawn`. Returns `0`. Rarely needs modification.

The HUD runner iterates the frames folder, requires each module, and spawns it in parallel. Each frame runs concurrently. A failing frame logs under the `[HUD]` prefix and does not block siblings. This parallel loading is what makes your UI feel snappy instead of sluggish. If you have ten UI frames and they each take 100ms to initialize, spawning them in parallel means your UI is ready in 100ms total, not 1000ms.

Do not modify the runner without understanding this loop. The parallel spawning and error isolation are deliberate design choices.

### client/utils

Helpers dedicated to the client side and its neighbor folders (classes, entities, controllers, services). If a utility only makes sense in a client context, it belongs here.

Same principle as `server/utils`: if it only works on the client, it goes here. If it could work on both sides, it belongs in `shared/utils`.

::: tip
If you are unsure where a module belongs, ask two questions: does it touch the network? Then `shared/events`. Is it pure data? Then `shared/index` or `shared/registry`. Everything else follows the lifecycle rules in [Contracts](/architecture/contracts).
:::

See [Contracts](/architecture/contracts) for what the bootstrapper expects from each module.
