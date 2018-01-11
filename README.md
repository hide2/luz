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

print("Http Server listening at http://0.0.0.0:8080/")
```

    luvit hello.lua

- rand.lua
```Lua
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
server:listen({port=8181}, onRequest)

print("Http Server listening at http://0.0.0.0:8181/")
```

    luvit rand.lua

## Benchmark
- luvit hello.lua

    ab -c 1000 -n 1000000 -k http://0.0.0.0:8080/

Requests per second: 30000 #/sec

- luvit rand.lua

    ab -c 1000 -n 1000000 -k http://0.0.0.0:8181/rand?n=1000000

Requests per second: 30000 #/sec