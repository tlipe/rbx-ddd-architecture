---
title: Registry
description: Registry and index data-module rules for the RBX DDD architecture. Single-expression return, no local-first assignment, no freeze.
---

# Registry

`shared/registry` and `shared/index` hold pure data. They record state, votes, registrations, catalogs. They are data, not APIs. The rule is mechanical: return the table directly in a single expression.

## Why pure data modules exist

Most Roblox projects scatter data everywhere. Item stats are hardcoded in services. Config values are buried in controllers. Catalogs are duplicated across multiple files. When you need to change a weapon's damage value, you're hunting through five different modules trying to find where it's defined.

Pure data modules solve this by centralizing all static data in one place. When you need to see what weapons exist in your game, you open `shared/registry/weapons.luau` and see the entire dataset in one return statement. No hunting. No piecing together. The data is right there.

This also makes data reusable. If both the server and client need to know about weapons, they both require the same module. There's no duplication, no drift, no confusion about which version is authoritative.

## Contract

- Location: `ReplicatedStorage/shared/registry/*.luau` or `shared/index/*.luau`.
- Form: single expression `return { key = value, ... }`.
- Forbidden: assigning to a local first, intermediate variables, `table.freeze()`, attached methods.
- Lookups: never on the data table. Wrap query/filter/lookup in `shared/utils/*Helper`.

## Wrong vs correct

Wrong — local-first assignment and freeze:

```luau
local weapons = {}
weapons.sword = { damage = 15 }
table.freeze(weapons)
return table.freeze(weapons)
```

The problem with this pattern isn't that `table.freeze()` is bad. The problem is that you're assigning to a local first, which means the table is mutable during construction. There's a window where the table could be modified before it's frozen. If another module requires this file during that window (which can happen with circular dependencies or complex initialization sequences), it gets a partially-constructed table.

Direct return removes that window entirely. The table is constructed and returned in one atomic operation. There's no moment where it's mutable and incomplete.

Correct — single expression, direct return:

```luau
return {
	sword = { damage = 15 },
}
```

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

## Why no intermediate locals

When you assign to a local first, you hide the shape of the data. A reader has to trace through the file to see what's being registered. They see `local weapons = {}`, then `weapons.sword = ...`, then `weapons.bow = ...`. By the time they reach the return statement, they've forgotten what was added.

With direct return, the entire dataset is visible in one place. You can see all the weapons, all their properties, all their relationships. The data shape is immediately obvious.

This matters for maintainability. Six months from now, when you're trying to remember what damage value you gave the Hunter Bow, you open the file and see it right there. You don't have to read through the entire construction logic.

## Why no methods on data tables

When you attach methods to a data table, you blur the line between data and behavior. The table becomes both a data structure and an API. This makes it harder to reason about. Is this a catalog of items, or is it an item manager? Does it just hold data, or does it also transform it?

By keeping data tables pure (no methods), you make it clear: this is just data. If you need to query, filter, or transform the data, that logic goes in `shared/utils/*Helper`. The helper is the API. The data table is just the data.

This separation also makes both easier to test. You can test the helper functions without touching the data. You can inspect the data without worrying about side effects from methods.

## Why no table.freeze()

Direct return removes the mutable window entirely. The table is constructed and returned in one expression. It's never mutable, even for a moment.

If you find yourself needing to mutate the data, it doesn't belong in registry/index. Move it to a service or class.

## Indexes vs registry

Same mechanics, different intent:

| Folder | Holds |
|---|---|
| `shared/index` | Catalog-style data: item lists, config tables, static mappings |
| `shared/registry` | Registration/vote records: who registered what, tally state, annotated runtime data |

Both use direct `return { ... }`. Neither attaches methods. Neither freezes.

The distinction is semantic, not mechanical. `shared/index` is for static catalogs: things that don't change at runtime. Item lists, config values, type definitions. `shared/registry` is for dynamic registrations: things that get added or modified as the game runs. Player votes, service registrations, runtime state annotations.

In practice, most projects use `shared/index` more than `shared/registry`. Static catalogs are more common than dynamic registrations. But both follow the same rules.

::: tip
If you need to mutate the table later, move it to a service or class. It does not belong in registry/index.
:::

Pure data modules are for data that doesn't change. If your data needs to be modified at runtime (like a player's inventory or a game session's state), it belongs in a service or class, not in a data module.

See [Contracts](/architecture/contracts) for how the bootstrapper treats these modules and [Folder Reference](/architecture/folder-reference) for placement.
