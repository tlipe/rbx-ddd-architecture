---
title: AI Integration
description: "How AI models work with RBX DDD Architecture and why smaller models perform well with this structure."
---

# AI Integration

This architecture works well with AI-assisted development because the structure is explicit and the contracts are strict. Models don't have to guess where code belongs or what shape it should take.

## Why AI models work here

The folder structure and module contracts remove ambiguity. When you ask an AI to create a service, it knows:

- Services go in `server/services/` or `client/services/`
- They initialize at require time and return either a table of methods or `return 0`
- They don't have a `start()` method
- They handle infrastructure, not orchestration

The same clarity applies to controllers, events, registries, and HUD frames. Each module type has one location, one return shape, and one responsibility. The bootstrapper validates these contracts at load time, so mistakes surface immediately instead of hiding until runtime.

## Smaller models perform well

You don't need the largest or most expensive model to work with this architecture. The explicit structure and clear contracts mean that smaller models (like GPT-4o-mini, Claude Haiku, or local models with 7-13B parameters) can generate correct code because the decision space is constrained.

When the architecture forces every module into one of five types with fixed locations and return shapes, the model doesn't have to reason about abstract patterns or make architectural decisions. It just follows the contract. The bootstrapper catches violations, so you get fast feedback when something doesn't match.

Developers have reported good results using this architecture with models that struggle on less structured projects. The convention-over-configuration approach means the model spends less time figuring out where things go and more time implementing the actual logic.

## The DDD skill

The dedicated DDD skill provides context-aware guidance for this architecture:

```bash
npx skills add https://github.com/tlipe/based-rbx-skills
```

The skill understands the folder structure, module contracts, and naming conventions. It generates code that follows the architecture rules and validates that your modules match the expected shapes. You can use it with any AI-powered editor or agent that supports skills.

**Learn more:**
- [Skills Repository](https://github.com/tlipe/based-rbx-skills)
- [DDD Skill Documentation](https://github.com/tlipe/based-rbx-skills/blob/main/skills/roblox-ddd/SKILL.md)

## Working with AI effectively

When asking an AI to generate code for this architecture:

**Be specific about the module type.** Say "create a service that handles inventory" instead of "add inventory logic." The model will know to put it in `server/services/`, return a table of methods, and avoid `start()`.

**Reference the contracts.** If you're using an editor with the DDD skill installed, the model has direct access to the architecture rules. Without the skill, point it to the [Contracts](/architecture/contracts) page or paste the relevant contract into the conversation.

**Let the bootstrapper validate.** Run your game after adding new modules. The bootstrapper logs clear errors when contracts don't match. Feed those errors back to the AI and it can fix the issue immediately.

**Start with examples.** The [Module examples](/#module-examples) in the README show the exact shape for each module type. Copy the structure and ask the AI to fill in the logic for your use case.

## Common patterns

**Service with methods:**
```luau
-- server/services/InventoryService.luau
local function addItem(player: Player, itemId: string, quantity: number)
end

local function removeItem(player: Player, itemId: string, quantity: number)
end

return {
    AddItem = addItem,
    RemoveItem = removeItem,
}
```

**Controller wiring signals:**
```luau
-- server/controllers/InventoryController.luau
const Players = game:GetService("Players")
const InventoryService = require(script.Parent.Parent.services.InventoryService)

local function onPlayerAdded(player: Player)
end

return {
    start = function(self)
        Players.PlayerAdded:Connect(onPlayerAdded)
    end,
}
```

**Event definition:**
```luau
-- shared/events/useItem.luau
const Packages = script.Parent.Parent.packages
const NetworkLib = require(Packages.NetworkLib)

NetworkLib.define("useItem", {
    fireServer = function(itemId: string)
    end,
})

return 0
```

These patterns are consistent across the architecture. Once the AI understands one example, it can generate others following the same shape.

## Limitations

AI models can still make mistakes with this architecture, especially around:

- **Confusing services and controllers.** Services initialize at require time and don't have `start()`. Controllers have `start()` and wire signals. If the model mixes these up, the bootstrapper will catch it.
- **Forgetting `return 0`.** Events, registries, indexes, and HUD frames all end with `return 0`. Models sometimes forget this because it's unusual. The bootstrapper validates the return value.
- **Placing modules in the wrong folder.** The folder structure is strict. A client-only module in `shared/` will cause issues. Always double-check the [Folder Reference](/architecture/folder-reference) if something doesn't load.

The strict contracts mean these mistakes are caught immediately, not after hours of debugging silent failures.
