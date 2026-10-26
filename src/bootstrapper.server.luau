local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")

local controllersFolder = script.Parent.controllers
local servicesFolder = script.Parent.services

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
		if not module:IsA("ModuleScript") then
			continue
		end

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
