---
title: Installation
description: "Install RBX DDD Architecture into a Roblox place by copy-paste or HttpService remote download."
---

# Installation

Getting the RBX DDD architecture into your Roblox place is straightforward, and you've got two solid options to choose from. Both approaches produce the exact same folder tree: `workspace/Client`, `workspace/Server`, `ReplicatedStorage/shared`, `ServerScriptService/server`, and `StarterPlayer/StarterPlayerScripts/client`. The choice between them comes down to whether you prefer working offline or always having the latest version at your fingertips.

Before we dive in, there's one important detail you should know: the files use the `.luau` Luau dialect (`const`, `type`, `::`, `+=`), not plain Lua. The reason for this is simple—Luau gives you proper type checking and modern syntax features that make your code more robust and easier to maintain. You'll notice the difference immediately when you start working with the architecture.

There's also a technical constraint worth mentioning: the installer must run as a **Script in ServerScriptService**. You might be tempted to paste it into the command bar, but that won't work because the command bar lacks the placement context the script needs to create instances in the right locations. Think of it this way—the script needs to "live" in the game world to build the game world.

::: warning
Files use the `.luau` Luau dialect (`const`, `type`, `::`, `+=`), not plain Lua. The installer must run as a **Script in ServerScriptService**. The command bar does NOT work for install; it lacks the placement context the script needs.
:::

## Option A — Copy and paste

This is the simplest approach and works completely offline. You're essentially copying the installer script directly from the repository into your place, which means you have full control over the version you're installing and you don't need to worry about network connectivity or HTTP permissions.

1. Open [`install.luau`](https://github.com/tlipe/rbx-ddd-architecture/blob/main/install.luau) from the repo.
2. In Studio, insert a new **Script** into `ServerScriptService`.
3. Paste the full contents of `install.luau` into that Script.
4. Run (Play Solo). The script builds the entire folder tree, bootstrappers, and contracts. Done.

That's it. You'll see the architecture appear in your Explorer window, ready to use. The installer script creates all the folders, bootstrapper scripts, and placeholder modules so you can start adding your game logic immediately. The beauty of this approach is that once you've done it once, you understand exactly what's being created and where everything lives.

## Option B — HttpService (remote download)

If you prefer to always get the latest version without manually copying files, this option pulls the installer straight from GitHub at runtime. It's convenient for teams that want to stay up-to-date automatically, but it does require your place to have HTTP requests enabled. The trade-off is clear: you gain convenience but introduce a network dependency.

This pulls the latest `install.luau` straight from GitHub at runtime.

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
Option B depends on the raw GitHub URL staying reachable. If the repo moves or the branch changes, update the `url` string. Option A has no network dependency.
:::

The trade-off here is convenience versus reliability. Option B means you always get the latest architecture version, but it requires an internet connection and HTTP permissions. Option A is bulletproof—once you have the file, you can install it anywhere, anytime. For most teams, we recommend starting with Option A during development and switching to Option B only if you need automatic updates across multiple projects.

After either option, the server bootstrapper loads services and controllers, then sets `workspace.ServerLoaded`. The client bootstrapper waits on that attribute before initializing. See [Introduction](/) for the full flow.

Now that you've got the architecture in place, you're ready to start building. The next logical step is understanding where everything goes—head over to the [folder reference](/architecture/folder-reference) to get a clear picture of the structure, or jump straight into creating your first [service](/modules/service) if you prefer learning by doing. Either way, you've got a solid foundation to work with.
