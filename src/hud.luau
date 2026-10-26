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
