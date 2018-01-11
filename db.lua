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