---
title: Registry
description: Registry and index data-module rules for the RBX DDD architecture. Single-expression return, no local-first assignment, no freeze.
---

# Registry

`shared/registry` and `shared/index` hold pure data. They record state, votes, registrations, catalogs. They are data, not APIs. The rule is mechanical: return the table directly in a single expression.

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

## Why these rules

- Intermediate locals hide the shape. A reader should see the whole table in one return statement.
- `table.freeze()` implies the table was mutable at some point. Direct return removes that window entirely.
- Methods on the data table blur data and behavior. Helpers in `shared/utils/*Helper` keep queries reusable and testable without touching the dataset.

## Indexes vs registry

Same mechanics, different intent:

| Folder | Holds |
|---|---|
| `shared/index` | Catalog-style data: item lists, config tables, static mappings |
| `shared/registry` | Registration/vote records: who registered what, tally state, annotated runtime data |

Both use direct `return { ... }`. Neither attaches methods. Neither freezes.

::: tip
If you need to mutate the table later, move it to a service or class. It does not belong in registry/index.
:::

See [Contracts](/architecture/contracts) for how the bootstrapper treats these modules and [Folder Reference](/architecture/folder-reference) for placement.
