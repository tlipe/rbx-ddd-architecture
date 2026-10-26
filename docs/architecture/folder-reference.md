---
title: Folder Reference
description: "Exact meaning of every folder in the RBX DDD architecture tree: workspace, shared, server, and client."
---

# Folder Reference

Every folder has one fixed purpose. Place a module in the right folder and its lifecycle is handled by the bootstrapper. The tree below is what the installer generates.

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

### workspace/Client

Folder holding all client-side rendered instances. Physical objects, visual effects, anything visible only to the local player.

### workspace/Server

Folder holding all server-authoritative instances. Visible to every player. Replicated physical objects, world effects, shared visuals.

## shared (ReplicatedStorage)

### shared/definitions

Schemas, contracts, types, enums, constants. Data shape agreements used across server and client.

### shared/events

All server-client connections live here. RemoteEvents, RemoteFunctions, network library wrappers. One ModuleScript per connection, named after the event (e.g. `purchaseItem.luau`). Inside: code that fires/listens on that connection. Pattern ends with `return 0`.

### shared/index

Pure data tables. Direct `return { ... }`. No methods attached. Query/filter/lookup helpers belong in `shared/utils/*Helper`. Indexes are data, not APIs.

### shared/registry

Registrar/voter environment. Modules that record or annotate state, votes, registrations. Single expression `return { key = value, ... }`. Never assign to local first. Never `table.freeze()`.

### shared/packages

ALL external libraries described as libraries. User-added (Warp, KoltStore, Spring). Nothing else lives here.

### shared/utils

Helper/utility ModuleScripts shared by BOTH sides. Pure functions reusable from server and client. Side-effect free and deterministic.

## server (ServerScriptService)

### server/bootstrapper

Script entry point. Loads services, then controllers, calls `start()` on each, sets `workspace.ServerLoaded`.

### server/classes

Stateful domain objects. Classes/enums dedicated to specific game objects.

### server/controllers

Orchestrate systems. Lifecycle hook: `function controllerName:start()`.

### server/services

Long-lived infrastructure. Initialized once. `return 0`. No `start()` method.

### server/utils

Helpers dedicated to the SERVER side and its neighbor folders (classes, controllers, services).

## client (StarterPlayerScripts)

### client/bootstrapper

LocalScript entry point. Waits for `ServerLoaded`, loads services, controllers, HUD, sets `workspace.ClientLoaded`.

### client/classes

Classes/enums scoped to the client. Same purpose as `server/classes` but client-side.

### client/entities

ModuleScripts acting 100% on in-game entities renderable on the client. Needs a server-client connection strategy. Optimization and rendering of entities, including players.

### client/controllers

Input handlers, camera, animations. Uses `start()`.

### client/services

AudioService/TweenService wrappers. `return 0`.

### client/ui/frames

One ModuleScript per UI surface. The module name IS the UI it programs (`shopCoin.luau`, `shopSwords.luau`, `inventoryFrame.luau`). Normal code building that interface. Ends `return 0`.

### client/ui/helpers

Quick reusable helpers scoped to the frames folder. Consumed by sibling frame modules.

### client/ui/hud

ModuleScript orchestrating frames via `task.spawn`. Returns `0`.

### client/utils

Helpers dedicated to the CLIENT side and its neighbor folders (classes, entities, controllers, services).

::: tip
If you are unsure where a module belongs, ask two questions: does it touch the network? then `shared/events`. Is it pure data? then `shared/index` or `shared/registry`. Everything else follows the lifecycle rules in [Contracts](/architecture/contracts).
:::