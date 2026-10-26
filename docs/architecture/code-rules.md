---
title: Code Rules
description: Naming conventions, const-vs-local binding rules, English-only requirement, and no-comments policy for the RBX DDD architecture.
---

# Code Rules

Strict conventions baked into the architecture. They apply to every `.luau` file in the tree.

## English only

Identifiers, strings, logs, and error messages are English. Zero Portuguese in code. This keeps the codebase readable to any contributor and searchable without locale assumptions.

## No comments

No comments unless explicitly requested. Names, types, and structure carry the intent. A comment that repeats the code is noise.

## Naming

| Case | Applies to |
|---|---|
| camelCase | Local variables, member values, functions, params, table keys |
| PascalCase | Types/classes and Roblox API references |
| LOUD_SNAKE_CASE | `const` bindings holding config or service references. Enum members exempt |

Correct:

```luau
const DataStoreService = game:GetService("DataStoreService")
const MAX_RETRIES = 3
type PlayerData = { coins: number, level: number }

local function loadData(player: Player): PlayerData?
	local result = {}
	return result
end
```

Incorrect:

```luau
local datastoreservice = game:GetService("DataStoreService")
const maxRetries = 3
type playerData = { coins: number, level: number }

local function LoadData(Player: Player): playerData?
	local Result = {}
	return Result
end
```

Rules broken above: service reference lowercased, config constant not LOUD_SNAKE_CASE, type not PascalCase, function not camelCase, param capitalized, local accumulator PascalCase.

## const vs local

Services are always `const`, never `local`. Module refs, configs, and singletons are `const`. Mutable state, loop counters, and accumulators are `local`.

| Binding kind | Keyword |
|---|---|
| Service reference | `const` |
| Module require / singleton | `const` |
| Config value | `const` |
| Mutable state | `local` |
| Loop counter | `local` |
| Accumulator | `local` |

Correct:

```luau
const Players = game:GetService("Players")
const DataService = require(script.Parent.Parent.services.DataStoreService)

local totalCoins = 0
for _, player in Players:GetPlayers() do
	totalCoins += player:GetAttribute("Coins")
end
```

Incorrect:

```luau
local Players = game:GetService("Players")
local DataService = require(script.Parent.Parent.services.DataStoreService)

const totalCoins = 0
```

`Players` and `DataService` are service/module refs and must be `const`. `totalCoins` is mutable state and must be `local`.

::: tip
Luau compiles both forms. The keyword choice is a readability contract enforced by convention, not by the compiler. Follow it so reviewers can tell an immutable ref from mutable state at a glance.
:::