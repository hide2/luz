local Http = require("./luz/http").Http
local JSON = require('rapidjson')

local function prepareHeader(req)
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

local function onRand(req)
	local n = req.args.n or 100
	local body = JSON.encode({n = n, rand = math.random(n)})
	print(body)
	return body
end

local function dispatchRequest(client, req)
	local header = prepareHeader(req)
	local body = ''
	if req.path == '/rand?n=1000000' then
		body = onRand(req)
	end
	client:respond(header, body)
end

local server = Http:new()
server:listen({port=8002}, dispatchRequest)

print("Http Server listening at http://0.0.0.0:8002/")