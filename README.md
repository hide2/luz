# luz - Building blazing fast APIs and micro-services

## Install
- Install Luvit

    curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh

- Install LuaRocks

    wget https://luarocks.org/releases/luarocks-2.4.3.tar.gz

    tar zxpf luarocks-2.4.3.tar.gz

    cd luarocks-2.4.3

    ./configure; make bootstrap

- Install rapidjson

    luarocks install rapidjson

## Usage
- hello.lua
```Lua
local Http = require("./luz/http").Http

local function onRequest(client, req)
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
server:listen({}, onRequest)

print("Http Server listening at http://0.0.0.0:8001/")
```

    luvit hello.lua

- rand.lua
```Lua
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
```

    luvit rand.lua

## Benchmark
- luvit hello.lua

    ab -c 1000 -n 1000000 -k http://0.0.0.0:8001/

Requests per second: 30000 #/sec

- luvit rand.lua

    ab -c 1000 -n 1000000 -k http://0.0.0.0:8002/rand/1000000

Requests per second: 30000 #/sec