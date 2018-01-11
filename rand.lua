local Http = require("./luz/http").Http

local function onRequest(client, req)
	p(req.path)
	local body = "Hello!"
	local header = {
		code = 200,
		{ "Server", "Luz" },
		{ "Content-Type", "text/plain" },
		{ "Content-Length", #body },
	}
	if req.keepAlive then
		header[#header + 1] = { "Connection", "Keep-Alive" }
	end
	client:respond(header, body)
end

local server = Http:new()
server:listen({port=8002}, onRequest)

print("Http Server listening at http://0.0.0.0:8002/")