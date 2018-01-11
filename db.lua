local Http = require("./luz/http").Http
local r = require("./luz/router").new()
local JSON = require("rapidjson")
local env = require("luasql.sqlite3").sqlite3()
local db = env:connect("/tmp/test.sqlite3")

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

local function onUser(params)
	local user
	for u in rows (db, "select * from user where id = "..params.id) do
		p(u)
		user = u
	end
	local body = JSON.encode(user)
	return body
end

local function dispatchRequest(client, req)
	local body = ''
	
	-- dispatch request urls here
	r:get('/user/:id', function(params)
		body = onUser(params)
	end)

	r:execute(req.method, req.path)
	local header = prepareHeader(req, body)
	client:respond(header, body)
end

local server = Http:new()
server:listen({port=8003}, dispatchRequest)

print("Http Server listening at http://0.0.0.0:8003/user/:id")