---
title: Registry
description: Registry and index data-module rules for the RBX DDD architecture. Single-expression return, no local-first assignment, no freeze.
---

# Registry

Let's talk about something that sounds trivial but isn't: data modules. In most Roblox projects, data gets scattered everywhere—hardcoded in scripts, buried in services, duplicated across files. This architecture takes a different approach. `shared/registry` and `shared/index` hold pure data. They record state, votes, registrations, catalogs. They are data, not APIs. The rule is mechanical: return the table directly in a single expression.

You might be thinking, "Why so strict about how I return a table?" It's a fair question. The reason is readability and maintainability at scale. When every data module follows the same pattern, you can open any file and immediately see the entire dataset in one return statement. No hunting through the file to piece together what's being registered. Six months from now, when you're trying to remember what damage value you gave the Hunter Bow, you'll thank past-you for this convention.

## Contract

- Location: `ReplicatedStorage/shared/registry/*.luau` or `shared/index/*.luau`.
- Form: single expression `return { key = value, ... }`.
- Forbidden: assigning to a local first, intermediate variables, `table.freeze()`, attached methods.
- Lookups: never on the data table. Wrap query/filter/lookup in `shared/utils/*Helper`.

The forbidden list might seem long, but it's all in service of one goal: making the data shape immediately visible.

## Wrong vs correct

Let's look at what not to do, and why:

Wrong — local-first assignment and freeze:

```luau
local weapons = {}
weapons.sword = { damage = 15 }
table.freeze(weapons)
return table.freeze(weapons)
```

Correct — single expression, direct return:

```luau
return {
	sword = { damage = 15 },
}
```

The wrong version has several problems. First, the intermediate local hides the shape—you have to read through the file to see what's being registered. Second, `table.freeze()` implies the table was mutable at some point. There's a window where the table could be modified before it's frozen. Direct return removes that window entirely.

Registry example:

```luau
-- shared/registry/weapons.luau
return {
	{
		id = "sword_basic",
		name = "Iron Sword",
		damage = 15,
	},
	{
		id = "bow_hunter",
		name = "Hunter Bow",
		damage = 22,
	},
}
```

Open this file and you immediately see the entire weapons dataset. No hunting, no piecing together. That's the goal.

## Why these rules

Let's dig into the reasoning behind each rule:

- Intermediate locals hide the shape. A reader should see the whole table in one return statement.
- `table.freeze()` implies the table was mutable at some point. Direct return removes that window entirely.
- Methods on the data table blur data and behavior. Helpers in `shared/utils/*Helper` keep queries reusable and testable without touching the dataset.

The separation of data and behavior is important. When your data tables are pure and immutable, you can reason about them without worrying about hidden side effects. And when your lookup logic is in utilities, it's reusable across multiple data tables and easy to test in isolation.

## Indexes vs registry

Same mechanics, different intent:

| Folder | Holds |
|---|---|
| `shared/index` | Catalog-style data: item lists, config tables, static mappings |
| `shared/registry` | Registration/vote records: who registered what, tally state, annotated runtime data |

Both use direct `return { ... }`. Neither attaches methods. Neither freezes.

The distinction is semantic, not mechanical. `shared/index` is for static catalogs—things that don't change at runtime. `shared/registry` is for dynamic registrations—things that get added or modified as the game runs. But from a code perspective, they follow the same rules.

::: tip
If you find yourself writing `local x = {}` followed by `x.key = ...`, stop. Collapse it into one `return { key = ..., ... }`. If you need to mutate the table later, it does not belong in registry/index — move it to a service or class.
:::

This is a good rule of thumb. If your data needs to change after it's created, it's not pure data—it's state. And state belongs in services or classes, not in data modules.

See [Contracts](/architecture/contracts) for how the bootstrapper treats these modules and [Folder Reference](/architecture/folder-reference) for placement.

Now that you understand data modules, you're ready to see how the UI layer works. Head over to [HUD Frame](/modules/hud-frame) to understand how UI surfaces are organized.
