local app = require("./luz/app").app:new()
local JSON = require('rapidjson')
local db = require("./luz/db").DB:new("sqlite3", "/tmp/test.sqlite3")

-- prepare db
db:run"DROP TABLE user"
db:run[[
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
  res = assert (db:run(string.format([[
    INSERT INTO user
    VALUES ('%s', '%s', '%s')]], p.id, p.name, p.email)
  ))
end

app:get('/user/:id', function(params)
	local user = db:select("select id, name, email from user where id = "..params.id, true)
	return JSON.encode(user)
end)
app:listen({port=8003})

print("Http Server listening at http://0.0.0.0:8003/user/:id")