local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

return {
	Client = {
		parent = workspace,
	},
	Server = {
		parent = workspace,
	},
	shared = {
		parent = ReplicatedStorage,
		childs = {
			definitions = {},
			events = {},
			index = {},
			packages = {},
			utils = {},
		}
	},
	server = {
		parent = ServerScriptService,
		childs = {
			classes = {},
			controllers = {},
			services = {},
			utils = {},
			bootstrapper = "script",
		}
	},
	client = {
		parent = StarterPlayer.StarterPlayerScripts,
		childs = {
			classes = {},
			entities = {},
			controllers = {},
			services = {},
			ui = {
				frames = {},
				helpers = {},
				hud = "script",
			},
			utils = {},
			bootstrapper = "script",
		}
	}
}
