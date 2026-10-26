-- Paste into a Script in ServerScriptService. Enable HttpService first.
-- Serves architecture payload as JSON at /architecture.

local HttpService = game:GetService("HttpService")
local Version = "1.1.0"

local PAYLOAD_URL = "https://raw.githubusercontent.com/tlipe/rbx-ddd-architecture/main/install.luau"

local function getPayload(): string
	local ok, result = pcall(function()
		return HttpService:GetAsync(PAYLOAD_URL)
	end)
	if not ok then
		error(`Failed to fetch payload: {result}`)
	end
	return result :: string
end

local function serve(): ()
	local json = HttpService:JSONEncode({
		Name = "Arquiteture",
		Version = Version,
		InstallUrl = PAYLOAD_URL,
		Payload = getPayload(),
	})
	print(json)
end

serve()
