---
title: Installation
description: "Install RBX DDD Architecture into a Roblox place by copy-paste or HttpService remote download."
---

# Installation

Two options, both producing the same tree: `workspace/Client`, `workspace/Server`, `ReplicatedStorage/shared`, `ServerScriptService/server`, and `StarterPlayer/StarterPlayerScripts/client`.

::: warning
Files use the `.luau` Luau dialect (`const`, `type`, `::`, `+=`), not plain Lua. The installer should run as a **Script in ServerScriptService** for proper context, though you can also execute it directly from the command bar if needed.
:::

## Option A — Copy and paste

1. Open [`install.luau`](https://github.com/tlipe/rbx-ddd-architecture/blob/main/install.luau) from the repo.
2. In Studio, insert a new **Script** into `ServerScriptService`.
3. Paste the full contents of `install.luau` into that Script.
4. Run (Play Solo). The script builds the entire folder tree, bootstrappers, and contracts — done.

After installation, the server bootstrapper loads services and controllers, then sets `workspace.ServerLoaded`. The client bootstrapper waits on that attribute before initializing. See [Introduction](/) for the full flow.
