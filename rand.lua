local Http = require("./luz/http").Http
local r = require("./luz/router").new()
local JSON = require('rapidjson')

local function prepareHeader(req, body)
	local header = {
		code = 200,
		{ "Server", "Luz" },
		{ "Content-Type", "text/plain" },
		{ "Content-Length", #body },
	}
	if req.keepAlive then
		header[#header + 1] = { "Connection", "Keep-Alive" }
	end
	return header
end

local function onRand(params)
	local n = params.n or 100
	local body = JSON.encode({n = n, rand = math.random(n)})
	return body
end

local function dispatchRequest(client, req)
	local body = ''
	
	-- dispatch request urls here
	r:get('/rand/:n', function(params)
		body = onRand(params)
	end)

	r:execute(req.method, req.path)
	local header = prepareHeader(req, body)
	client:respond(header, body)
end

local server = Http:new()
server:listen({port=8002}, dispatchRequest)

print("Http Server listening at http://0.0.0.0:8002/")