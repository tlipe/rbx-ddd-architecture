<div align="center">

# RBX DDD Architecture

**Domain-Driven Design para Roblox Studio.**

Instalação em um clique. Bootstrapper server/client automático. Convenções prontas para jogos de qualquer escala.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](#)
[![Roblox](https://img.shields.io/badge/Roblox-Luau-red.svg)](https://www.roblox.com)

</div>

---

## Por que usar

| Benefício | Detalhe |
|---|---|
| **Setup instantâneo** | Um script monta toda a árvore de pastas, bootstrappers e contratos. Zero configuração manual. |
| **Convenção sobre configuração** | Serviços carregam sozinhos. Controllers registram `start()`. Nada de wiring manual entre módulos. |
| **Server-client sincronizado** | Client espera `ServerLoaded` antes de inicializar. Sem race conditions no startup. |
| **Escala sem refatorar** | Começa com 3 serviços, cresce para 30 sem mudar a estrutura. Adiciona módulo na pasta certa, está pronto. |
| **Observabilidade nativa** | LogService integrado. Cada carga/falha aparece no Output do Studio com contexto claro. |
| **Contrato explícito** | Interfaces tipadas (`Controller`, service return). Erros de contrato falham no load, não em runtime silencioso. |

---

## Como funciona

### Fluxo de inicialização

```
Studio Play
    │
    ▼
server/bootstrapper (Script)
    ├── carrega services/*.lua ──► require + contagem
    ├── carrega controllers/*.lua ──► require + valida start()
    ├── executa controller:start() em ordem
    └── workspace.ServerLoaded = true
            │
            ▼
client/bootstrapper (LocalScript)
    ├── aguarda ServerLoaded (GetAttributeChangedSignal)
    ├── carrega services/*.lua
    ├── carrega controllers/*.lua
    ├── carrega ui/hud
    └── workspace.ClientLoaded = true
```

### Árvore gerada

```
ReplicatedStorage/
└── shared/                    ← código compartilhado
    ├── definitions/           ← tipos, enums, constantes
    ├── events/                ← RemoteEvent/RemoteFunction wrappers
    ├── index/                 ← barrel exports
    ├── packages/              ← libs externas
    └── utils/                 ← helpers puros

ServerScriptService/
└── server/                    ← lógica autoritativa
    ├── bootstrapper           ← Script (entry point)
    ├── classes/               ← modelos de domínio (DDD entities/value objects)
    ├── controllers/           ← orquestração de casos de uso
    ├── services/              ← infraestrutura (DataStore, HTTP, messaging)
    └── utils/                 ← helpers server-only

StarterPlayer/StarterPlayerScripts/
└── client/                    ← apresentação e predição
    ├── bootstrapper           ← LocalScript (entry point)
    ├── classes/               ← clientes de entidades remotas
    ├── entities/              ← estados locais do jogador/mundo
    ├── controllers/           ← input handlers, câmera, animações
    ├── services/              ← AudioService, TweenService wrappers
    ├── ui/
    │   ├── frames/            ← componentes ScreenGui individuais
    │   ├── helpers/           ← utilitários de UI (layout, theme)
    │   └── hud                ← ModuleScript (orquestra frames)
    └── utils/                 ← helpers client-only
```

---

## Instalação

<div align="center">

### Opção A — Copiar e colar

Abra [`install.lua`](install.lua), cole num Script novo em ServerScriptService, rode. Pronto.

</div>

### Opção B — HttpService (download remoto)

1. Game Settings → Security → **Allow HTTP Requests**: ON
2. Crie um Script em ServerScriptService:

```lua
local HttpService = game:GetService("HttpService")
local url = "https://raw.githubusercontent.com/tlipe/rbx-ddd-architecture/main/install.lua"
local ok, source = pcall(HttpService.GetAsync, HttpService, url)
if not ok then error(source) end
loadstring(source)()
```

3. Rode. O script baixa a versão mais recente direto do GitHub.

---

## Escrevendo seu primeiro módulo

### Service

Um service é um ModuleScript que retorna uma tabela com métodos. Não precisa chamar nada especial — o bootstrapper faz `require` automaticamente.

```lua
-- server/services/DataStoreService.lua
local DataStoreService = game:GetService("DataStoreService")

local store = DataStoreService:GetDataStore("PlayerData_v1")

return {
	Load = function(player: Player): {[string]: any}?
		local ok, result = pcall(store.GetAsync, store, `player_{player.UserId}`)
		if not ok then
			warn(`[DataService] Load failed for {player.Name}: {result}`)
			return nil
		end
		return result
	end,

	Save = function(player: Player, data: {[string]: any}): boolean
		local ok, err = pcall(store.SetAsync, store, `player_{player.UserId}`, data)
		if not ok then
			warn(`[DataService] Save failed for {player.Name}: {err}`)
			return false
		end
		return true
	end,
}
```

### Controller

Um controller deve retornar `{ start = function(self) }`. O bootstrapper chama `start()` após todos os services carregarem.

```lua
-- server/controllers/PlayerJoinController.lua
local Players = game:GetService("Players")
local DataService = require(script.Parent.Parent.services.DataStoreService)

return {
	start = function(self)
		Players.PlayerAdded:Connect(function(player)
			local data = DataService.Load(player)
			if not data then
				data = { coins = 0, level = 1 }
			end
			player:SetAttribute("Coins", data.coins)
			player:SetAttribute("Level", data.level)
		end)

		Players.PlayerRemoving:Connect(function(player)
			DataService.Save(player, {
				coins = player:GetAttribute("Coins"),
				level = player:GetAttribute("Level"),
			})
		end)
	end,
}
```

### HUD Frame

Cada frame em `client/ui/frames/` é um ModuleScript que retorna uma função. O `hud` runner chama todas em paralelo via `task.spawn`.

```lua
-- client/ui/frames/CoinCounter.lua
local CoinsLabel = script.Parent:WaitForChild("CoinsLabel"):: TextLabel

return function()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		-- reposition logic
	end)

	game.Players.LocalPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
		local coins = game.Players.LocalPlayer:GetAttribute("Coins")
		CoinsLabel.Text = `${coins} coins`
	end)
end
```

---

## Contratos

| Caminho | Tipo | Contrato |
|---|---|---|
| `*/services/*.lua` | ModuleScript | Retorna `table`. Qualquer método público. Falha no require aborta aquele service mas continua os outros. |
| `*/controllers/*.lua` | ModuleScript | Retorna `{ start: (self) -> () }`. Bootstrapper valida tipo e presença de `start`. |
| `client/ui/frames/*.lua` | ModuleScript | Retorna `function()`. Executado em `task.spawn` pelo HUD runner. |
| `client/ui/hud` | ModuleScript | Orquestrador interno. Não modificar sem entender o loop de frames. |

---

## Debugging

Todos os logs usam prefixos estruturados:

```
[SERVICE] Loading DataStoreService...
[SERVICE] Loaded DataStoreService.
[CONTROLLER] Registered PlayerJoinController.
[CONTROLLER] Start failed #2: attempt to index nil value
[SERVER] Server fully loaded in 0.04s.
[CLIENT] Waiting for server...
[CLIENT] Server loaded. Timestamp: 1730000000
[HUD] Bootstrap runtime error: CoinCounter -> ...
```

Se `ServerLoaded` ficar `false`, abra o Output e procure por `[SERVICE] Failed` ou `[CONTROLLER]` com erro. Corrija o módulo problemático; o bootstrapper não avança com falhas.

---

## Versionamento

| Versão | Mudanças |
|---|---|
| 1.1.0 | Separação server/client bootstrapper, HUD frame runner, validação de contrato |
| 1.0.0 | Estrutura inicial, tree builder, log_stdio |

---

## Licença

MIT. Use livremente em projetos comerciais e pessoais.
