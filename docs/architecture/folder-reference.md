---
title: Folder Reference
description: "Exact meaning of every folder in the RBX DDD architecture tree: workspace, shared, server, and client."
---

# Folder Reference

Every folder has one fixed purpose. Place a module in the right folder and its lifecycle is handled by the bootstrapper.

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

Split into two subfolders that separate client-only visuals from server-authoritative objects.

### workspace/Client

Client-side rendered instances. Physical objects, visual effects, anything visible only to the local player. Local particle effects, temporary markers.

### workspace/Server

Server-authoritative instances. Visible to every player. Replicated physical objects, world effects, shared visuals.

## shared (ReplicatedStorage)

Server and client meet here. Everything is replicated to both sides, so modules must be safe for both contexts. Typically pure data, network definitions, or utility functions.

### shared/definitions

Schemas, contracts, types, enums, constants. Data shape agreements used across server and client.

### shared/events

Server-client connections. RemoteEvents, RemoteFunctions, network library wrappers. One ModuleScript per connection, named after the event (e.g., `purchaseItem.luau`). Ends with `return 0`.

### shared/index

Pure data tables. Direct `return { ... }`. No methods attached. Query, filter, and lookup helpers belong in `shared/utils/*Helper`.

### shared/registry

Registrar or voter environment. Modules record or annotate state, votes, registrations. Single expression: `return { key = value, ... }`. Never assign to a local first. Never use `table.freeze()`.

### shared/packages

External libraries only. User-added packages like Warp, KoltStore, Spring. Nothing project-specific belongs here.

### shared/utils

Helper and utility ModuleScripts shared by both sides. Pure functions reusable from server and client. Side-effect free and deterministic.

## server (ServerScriptService)

Server-side logic. The authoritative side that validates, persists, and orchestrates gameplay systems.

### server/bootstrapper

Script entry point. Loads services, then controllers, calls `start()` on each, sets `workspace.ServerLoaded`. Rarely needs modification.

### server/classes

Stateful domain objects. Classes and enums dedicated to specific game objects.

### server/controllers

Orchestrate systems. Lifecycle hook: `function controllerName:start()`. Wire up gameplay systems, connect signals, drive the flow.

### server/services

Long-lived infrastructure. Initialized once when required. Return either a table of public methods or `return 0` if side-effect only. No `start()` method.

### server/utils

Helpers dedicated to the server side and its neighbor folders (classes, controllers, services).

## client (StarterPlayerScripts)

Mirrors the server structure but handles everything that runs on the player's machine. Input, rendering, UI, camera control.

### client/bootstrapper

LocalScript entry point. Waits for `ServerLoaded`, loads services, controllers, HUD, sets `workspace.ClientLoaded`. Rarely needs modification.

### client/classes

Classes and enums scoped to the client. Same purpose as `server/classes` but client-side.

### client/entities

ModuleScripts acting on in-game entities renderable on the client. Need a server-client connection strategy. Handle optimization and rendering of entities, including players.

### client/controllers

Input handlers, camera control, animations. Use `start()` like server controllers. Orchestrate the player's direct experience.

### client/services

AudioService/TweenService wrappers and similar client-side infrastructure. Return `0` or a table of methods, like server services.

### client/ui/frames

One ModuleScript per UI surface. The module name is the UI it programs (`shopCoin.luau`, `shopSwords.luau`, `inventoryFrame.luau`). Normal code building that interface. Always ends with `return 0`.

### client/ui/helpers

Reusable helpers scoped to the frames folder. Consumed by sibling frame modules. Formatting functions, animation builders, layout utilities.

### client/ui/hud

ModuleScript that orchestrates frames via `task.spawn`. Returns `0`. Rarely needs modification.

### client/utils

Helpers dedicated to the client side and its neighbor folders (classes, entities, controllers, services).

::: tip
If you are unsure where a module belongs, ask two questions: does it touch the network? then `shared/events`. Is it pure data? then `shared/index` or `shared/registry`. Everything else follows the lifecycle rules in [Contracts](/architecture/contracts).
:::

See [Contracts](/architecture/contracts) for what the bootstrapper expects from each module.
