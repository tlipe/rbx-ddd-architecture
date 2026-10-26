---
title: Code Rules
description: Naming conventions, const-vs-local binding rules, English-only requirement, and no-comments policy for the RBX DDD architecture.
---

# Code Rules

Every codebase has conventions, and the RBX DDD architecture is no exception. These rules might seem strict at first, but they exist for a reason: consistency makes code readable, searchable, and maintainable. When everyone on the team follows the same patterns, you spend less time deciphering code and more time building features.

You'll notice that these conventions are designed to make code self-documenting. The goal is that you can understand what a piece of code does just by reading it—no comments needed, no context switching, no mental overhead. When you follow these rules, your code becomes predictable in the best way possible.

These conventions are baked into the architecture and apply to every `.luau` file in the tree. Let's walk through them.

## English only

Identifiers, strings, logs, and error messages are English. Zero Portuguese in code. This might feel unnatural if you're a Portuguese speaker, but there's a practical reason: it keeps the codebase readable to any contributor and searchable without locale assumptions.

When your code is entirely in English, you can use standard search tools, documentation generators, and collaboration features without worrying about character encoding or language-specific quirks. It also makes it easier to onboard international contributors down the line. Think of it as making your codebase globally accessible—it's a small sacrifice in comfort for a big gain in reach.

## No comments

This one might surprise you: no comments unless explicitly requested. The philosophy here is that names, types, and structure should carry the intent. A comment that repeats the code is noise.

You might be thinking, "But what if I need to explain why I did something?" The answer is that if you need a comment to explain what the code does, the code probably isn't clear enough. Rename variables, extract functions, add type annotations. If you need to explain a non-obvious decision, that's what documentation is for—not inline comments.

The reason we enforce this is that comments go stale. Code changes, but comments often don't. A wrong comment is worse than no comment at all, because it actively misleads readers. It's like having a map with outdated information—you're better off with no map at all.

Think of it this way: every comment is a promise that the code will always match the comment's description. That's a promise that's hard to keep over time. By eliminating comments, we eliminate that maintenance burden.

## Naming

Naming is one of the hardest problems in programming, so we've made it simple: follow the case conventions, and you'll never have to guess.

| Case | Applies to |
|---|---|
| camelCase | Local variables, member values, functions, params, table keys |
| PascalCase | Types/classes and Roblox API references |
| LOUD_SNAKE_CASE | `const` bindings holding config or service references. Enum members exempt |

The reason for these distinctions is that they make the code's intent immediately visible. When you see `LOUD_SNAKE_CASE`, you know it's a constant. When you see `PascalCase`, you know it's a type or class. When you see `camelCase`, you know it's a variable or function. It's like having a color-coded system for your code—you can tell what something is just by looking at its shape.

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

Let's break down what went wrong in the incorrect example: the service reference is lowercased (should be `PascalCase` for Roblox API), the config constant isn't `LOUD_SNAKE_CASE`, the type isn't `PascalCase`, the function isn't `camelCase`, the parameter is capitalized, and the local accumulator is `PascalCase` when it should be `camelCase`. Each of these violations makes the code harder to read because you can't rely on naming to tell you what something is.

These conventions take a bit of practice, but once they become habit, you'll find that reading code becomes much easier. You can tell at a glance what's a constant, what's a type, and what's a variable. It's like learning a new language—awkward at first, but eventually second nature.

## const vs local

This is one of the most important conventions in the architecture. Services are always `const`, never `local`. Module refs, configs, and singletons are `const`. Mutable state, loop counters, and accumulators are `local`.

| Binding kind | Keyword |
|---|---|
| Service reference | `const` |
| Module require / singleton | `const` |
| Config value | `const` |
| Mutable state | `local` |
| Loop counter | `local` |
| Accumulator | `local` |

The reason we distinguish between `const` and `local` is readability. When you see `const`, you know that binding won't change. When you see `local`, you know it might. This makes it much easier to reason about the code—you don't have to track whether a service reference gets reassigned somewhere.

Think of `const` as a promise: "This binding will never change." When you see `const Players = game:GetService("Players")`, you know that `Players` will always refer to the Players service. You don't have to scan the rest of the file to check if it gets reassigned. That's a cognitive load you don't have to carry.

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

In the incorrect example, `Players` and `DataService` are service/module refs and must be `const`. `totalCoins` is mutable state and must be `local`. Using `local` for a service reference suggests it might change, which is misleading. Using `const` for a mutable value is just wrong—it's a lie encoded in your code.

::: tip
Luau compiles both forms. The keyword choice is a readability contract enforced by convention, not by the compiler. Follow it so reviewers can tell an immutable ref from mutable state at a glance.
:::

These rules might feel restrictive at first, but they're designed to make your codebase more maintainable as it grows. When everyone follows the same conventions, code reviews become faster, onboarding becomes easier, and bugs become harder to hide. It's the difference between a well-organized library and a pile of books—both contain the same information, but one is much easier to navigate.

Now that you understand the naming and binding conventions, you're ready to start writing code that fits seamlessly into the architecture. Head over to [Service](/modules/service) to see these rules in action, or check [Contracts](/architecture/contracts) to understand what each module type must return.
