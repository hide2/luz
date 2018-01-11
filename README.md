# luz - Building blazing fast APIs and micro-services
luz gets 3X performance of Nodejs, 4.5X of Express, 18X of Lumen.

See benchmark result of the same "hello" example with single process:
- luz: 27000 #/sec
- Node.js: 9000 #/sec
- Express: 6000 #/sec
- Lumen: 1500 #/sec

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
local app = require("./luz/app").app:new()

app:get('/', function()
	return "hello"
end)
app:listen({port=8001})

print("Http Server listening at http://0.0.0.0:8001/")
```

- echo.lua(with routing and JSON codec)
```Lua
local app = require("./luz/app").app:new()
local JSON = require('rapidjson')

app:get('/echo/:msg', function(params)
	return JSON.encode({ msg = params.msg})
end)
app:listen({port=8002})

print("Http Server listening at http://0.0.0.0:8002/echo/:msg")
```

- db.lua(with routing and JSON codec and SQLite)
```Lua
local app = require("./luz/app").app:new()
local JSON = require('rapidjson')
local db = require("luasql.sqlite3").sqlite3():connect("/tmp/test.sqlite3")

-- prepare db
db:execute"DROP TABLE user"
db:execute[[
  CREATE TABLE user(
    id  INT PRIMARY KEY,
    name  VARCHAR(50),
    email VARCHAR(50)
  )
]]
local list = {
  { id=1, name="Jose das Couves", email="jose@couves.com", },
  { id=2, name="Manoel Joaquim", email="manoel.joaquim@cafundo.com", },
  { id=3, name="Maria das Dores", email="maria@dores.com", },
}
for i, p in pairs (list) do
  res = assert (db:execute(string.format([[
    INSERT INTO user
    VALUES ('%s', '%s', '%s')]], p.id, p.name, p.email)
  ))
end
local function rows (connection, sql_statement)
  local cursor = assert (connection:execute (sql_statement))
  return function ()
    return cursor:fetch()
  end
end

app:get('/user/:id', function(params)
	local user
	for id, name, email in rows (db, "select id, name, email from user where id = "..params.id) do
		user = {id = id, name = name, email = email}
	end
	return JSON.encode(user)
end)
app:listen({port=8003})

print("Http Server listening at http://0.0.0.0:8003/user/:id")
```

## Benchmark
- luvit hello.lua

    ab -c 1000 -n 1000000 -k http://0.0.0.0:8001/
    Requests per second: 27000 #/sec

- luvit echo.lua

    ab -c 1000 -n 1000000 -k http://0.0.0.0:8002/echo/hello
    Requests per second: 24000 #/sec

- luvit db.lua

    ab -c 1000 -n 1000000 -k http://0.0.0.0:8003/user/1
    Requests per second: 10000 #/sec