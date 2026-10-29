---
title: Installation
description: "Install RBX DDD Architecture into a Roblox place by copy-paste or HttpService remote download."
---

# Installation

Two options. Both produce the same tree: `workspace/Client`, `workspace/Server`, `ReplicatedStorage/shared`, `ServerScriptService/server`, and `StarterPlayer/StarterPlayerScripts/client`.

::: warning
Files use the `.luau` Luau dialect (`const`, `type`, `::`, `+=`), not plain Lua. The installer must run as a **Script in ServerScriptService**. The command bar does NOT work for install; it lacks the placement context the script needs.
:::

## Option A — Copy and paste

1. Open [`install.luau`](https://github.com/tlipe/rbx-ddd-architecture/blob/main/install.luau) from the repo.
2. In Studio, insert a new **Script** into `ServerScriptService`.
3. Paste the full contents of `install.luau` into that Script.
4. Run (Play Solo). The script builds the entire folder tree, bootstrappers, and contracts. Done.

## Option B — HttpService (remote download)

This pulls the latest `install.luau` from GitHub at runtime.

1. Enable HTTP: **Game Settings → Security → Allow HTTP Requests: ON**.

::: warning
HttpService requires **Allow HTTP Requests** to be ON in Game Settings → Security. Without it, `GetAsync` fails with a 403 and nothing installs.
:::

2. Insert a new **Script** into `ServerScriptService` and paste:

```luau
local HttpService = game:GetService("HttpService")
local url = "https://raw.githubusercontent.com/tlipe/rbx-ddd-architecture/main/install.luau"
local ok, source = pcall(HttpService.GetAsync, HttpService, url)
if not ok then error(source) end
loadstring(source)()
```

3. Run (Play Solo). The script downloads and executes the latest installer.

::: info
Option B requires the raw GitHub URL to be reachable. If the repo moves or the branch changes, update the `url` string. Option A has no network dependency.
:::

After either option, the server bootstrapper loads services and controllers, then sets `workspace.ServerLoaded`. The client bootstrapper waits on that attribute before initializing. See [Introduction](/) for the full flow.
