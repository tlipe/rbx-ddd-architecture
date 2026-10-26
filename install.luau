-- Paste this into a Script in ServerScriptService and run.

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")
const StarterPlayer = game:GetService("StarterPlayer")

const Version = "1.1.0"

const bootstrapper_server_code = [[
const LogService = game:GetService("LogService")
const RunService = game:GetService("RunService")

const controllersFolder = script.Parent.controllers
const servicesFolder = script.Parent.services

type Controller = {
	start: (self: Controller) -> ()
}

local controllers: {Controller} = {}

local function log_stdio(msgtype: "error" | "warn" | "info", message: string): ()
	if RunService:IsStudio() then
		if msgtype == "error" then LogService:Error(message) end
		if msgtype == "warn" then LogService:Warn(message) end
		if msgtype == "info" then LogService:Info(message) end
	end
end

local function loadServices(): (number, number)
	local loaded = 0
	local failed = 0
	for _, module in servicesFolder:GetChildren() do
		if not module:IsA("ModuleScript") then continue end
		log_stdio("info", `[SERVICE] Loading {module.Name}...`)
		local ok, result = pcall(require, module)
		if ok then
			loaded += 1
			log_stdio("info", `[SERVICE] Loaded {module.Name}.`)
		else
			failed += 1
			log_stdio("error", `[SERVICE] Failed {module.Name}: {result}`)
		end
	end
	return loaded, failed
end

local function loadControllers(): (number, number)
	local loaded = 0
	local failed = 0
	for _, module in controllersFolder:GetChildren() do
		if not module:IsA("ModuleScript") then continue end
		local ok, result = pcall(require, module)
		if not ok then
			failed += 1
			log_stdio("error", `[CONTROLLER] Require failed {module.Name}: {result}`)
			continue
		end
		if typeof(result) ~= "table" then
			failed += 1
			log_stdio("error", `[CONTROLLER] Invalid return type: {module.Name}`)
			continue
		end
		if typeof(result.start) ~= "function" then
			failed += 1
			log_stdio("error", `[CONTROLLER] Missing start(): {module.Name}`)
			continue
		end
		local controller = result :: Controller
		table.insert(controllers, controller)
		loaded += 1
		log_stdio("info", `[CONTROLLER] Registered {module.Name}.`)
	end
	for index, controller in controllers do
		local ok, err = pcall(function()
			controller:start()
		end)
		if not ok then
			failed += 1
			log_stdio("error", `[CONTROLLER] Start failed #{index}: {err}`)
		end
	end
	return loaded, failed
end

local function boot(): ()
	local startedAt = os.clock()
	workspace:SetAttribute("ServerLoaded", false)
	log_stdio("info", "[SERVER] Starting initialization...")
	local servicesLoaded, servicesFailed = loadServices()
	log_stdio("info", `[SERVICES] {servicesLoaded} loaded, {servicesFailed} failed.`)
	local controllersLoaded, controllersFailed = loadControllers()
	log_stdio("info", `[CONTROLLERS] {controllersLoaded} loaded, {controllersFailed} failed.`)
	local hasFailures = servicesFailed > 0 or controllersFailed > 0
	if hasFailures then
		log_stdio("error", "[SERVER] Initialization completed with failures. ServerLoaded will remain false.")
		return
	end
	workspace:SetAttribute("ServerLoadedTimestamp", os.time())
	workspace:SetAttribute("ServerLoaded", true)
	log_stdio("info", `[SERVER] Server fully loaded in {os.clock() - startedAt}s.`)
end

boot()
]]

local hud_client_code = [[
local frames_setup: Instance = script.Parent.frames

local _require = require
local _spawn = task.spawn
local _warn = warn

local function run(module: ModuleScript): ()
	local ok: boolean, result: any = pcall(_require, module)
	if not ok then
		_warn(`[HUD] Bootstrap require error: {module:GetFullName()} -> {result}`)
		return
	end
	if typeof(result) == 'function' then
		local ok2: boolean, err: any = pcall(result)
		if not ok2 then
			_warn(`[HUD] Bootstrap runtime error: {module:GetFullName()} -> {err}`)
		end
	end
end

local function init(): ()
	for _, child in frames_setup:GetChildren() do
		if child:IsA('ModuleScript') then
			local module: ModuleScript = child
			_spawn(function() run(module) end)
		end
	end
end

_spawn(init)
return 1
]]

local bootstrapper_client_code = [[
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")

local controllersFolder = script.Parent.controllers
local servicesFolder = script.Parent.services
local hud = script.Parent.ui.hud

type Controller = {
	start: (self: Controller) -> ()
}

local controllers: {Controller} = {}

local function log_stdio(msgtype: "error" | "warn" | "info", message: string): ()
	if RunService:IsStudio() then
		if msgtype == "error" then LogService:Error(message) end
		if msgtype == "warn" then LogService:Warn(message) end
		if msgtype == "info" then LogService:Info(message) end
	end
end

local function waitForServer(): ()
	if workspace:GetAttribute("ServerLoaded") == true then
		log_stdio("info", "[CLIENT] Server already loaded.")
		return
	end
	log_stdio("info", "[CLIENT] Waiting for server...")
	local signal = workspace:GetAttributeChangedSignal("ServerLoaded")
	while workspace:GetAttribute("ServerLoaded") ~= true do
		signal:Wait()
	end
	local timestamp = workspace:GetAttribute("ServerLoadedTimestamp")
	log_stdio("info", `[CLIENT] Server loaded. Timestamp: {timestamp}`)
end

local function loadServices(): (number, number)
	local loaded = 0
	local failed = 0
	for _, module in servicesFolder:GetChildren() do
		if not module:IsA("ModuleScript") then continue end
		log_stdio("info", `[SERVICE] Loading {module.Name}...`)
		local ok, result = pcall(require, module)
		if ok then
			loaded += 1
			log_stdio("info", `[SERVICE] Loaded {module.Name}`)
		else
			failed += 1
			log_stdio("error", `[SERVICE] Failed {module.Name}: {result}`)
		end
	end
	return loaded, failed
end

local function loadControllers(): (number, number)
	local loaded = 0
	local failed = 0
	for _, module in controllersFolder:GetChildren() do
		if not module:IsA("ModuleScript") then continue end
		local ok, result = pcall(require, module)
		if not ok then
			failed += 1
			log_stdio("error", `[CONTROLLER] Require failed {module.Name}: {result}`)
			continue
		end
		if typeof(result) ~= "table" then
			failed += 1
			log_stdio("error", `[CONTROLLER] Invalid return type: {module.Name}`)
			continue
		end
		if typeof(result.start) ~= "function" then
			failed += 1
			log_stdio("error", `[CONTROLLER] Missing start(): {module.Name}`)
			continue
		end
		local controller = result :: Controller
		table.insert(controllers, controller)
		loaded += 1
		log_stdio("info", `[CONTROLLER] Registered {module.Name}`)
	end
	for index, controller in controllers do
		local ok, err = pcall(function()
			controller:start()
		end)
		if not ok then
			failed += 1
			log_stdio("error", `[CONTROLLER] Start failed #{index}: {err}`)
		end
	end
	return loaded, failed
end

local function loadHud(): boolean
	local ok, err = pcall(require, hud)
	if not ok then
		log_stdio("error", `[HUD] Failed to load: {err}`)
		return false
	end
	log_stdio("info", "[HUD] Loaded.")
	return true
end

local function boot(): ()
	local startedAt = os.clock()
	waitForServer()
	local servicesLoaded, servicesFailed = loadServices()
	log_stdio("info", `[SERVICES] {servicesLoaded} loaded, {servicesFailed} failed.`)
	local controllersLoaded, controllersFailed = loadControllers()
	log_stdio("info", `[CONTROLLERS] {controllersLoaded} loaded, {controllersFailed} failed.`)
	local hudLoaded = loadHud()
	local hasFailures = servicesFailed > 0 or controllersFailed > 0 or not hudLoaded
	if hasFailures then
		log_stdio("error", "[CLIENT] Initialization completed with failures.")
	else
		workspace:SetAttribute("ClientLoaded", true)
		workspace:SetAttribute("ClientLoadedTimestamp", os.time())
		log_stdio("info", "[CLIENT] Client fully loaded.")
	end
	log_stdio("info", `[CLIENT] Boot finished in {os.clock() - startedAt}s.`)
end

boot()
]]

local Parents = {
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
			registry = {},
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
			bootstrapper = bootstrapper_server_code,
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
				hud = hud_client_code,
			},
			utils = {},
			bootstrapper = bootstrapper_client_code,
		}
	}
}

local function getOrCreateFolder(name: string, parent: Instance): Folder
	local existing: Instance? = parent:FindFirstChild(name)
	if existing and existing:IsA('Folder') then
		return existing :: Folder
	end
	if existing then existing:Destroy() end
	local folder = Instance.new('Folder')
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function createScript(name: string, parent: Instance, source: string): ()
	local existing: Instance? = parent:FindFirstChild(name)
	if existing then existing:Destroy() end
	local isClient: boolean = parent:IsDescendantOf(StarterPlayer.StarterPlayerScripts)
	local obj: LuaSourceContainer
	if name == 'bootstrapper' then
		obj = if isClient then Instance.new('LocalScript') else Instance.new('Script')
	else
		obj = Instance.new('ModuleScript')
	end
	obj.Name = name
	obj.Source = source
	obj.Parent = parent
end

local function resolve(name: string, value: any, parent: Instance): ()
	local t = typeof(value)
	if t == 'table' then
		local folder = getOrCreateFolder(name, parent)
		for childName, childValue in value do
			resolve(childName, childValue, folder)
		end
		return
	end
	if t == 'string' then
		createScript(name, parent, value)
		return
	end
	warn(`[BUILD] Invalid type: {name}`)
end

local function build(tree: {[string]: any}): ()
	for rootName, config in tree do
		if typeof(config) ~= 'table' then continue end
		local parent: Instance? = config.parent
		local childs: {[string]: any}? = config.childs
		if not parent then
			warn(`[BUILD] Invalid parent: {rootName}`)
			continue
		end
		local rootFolder: Folder = getOrCreateFolder(rootName, parent :: Instance)
		if typeof(childs) ~= 'table' then continue end
		for name, value in childs :: {[string]: any} do
			resolve(name, value, rootFolder)
		end
	end
end

build(Parents)

print(`Architecture built successfully. Version: {Version}`)
