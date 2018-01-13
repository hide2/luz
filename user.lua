local app = require("./luz/app").app:new()
local Model = require("./luz/model").Model
local JSON = require('rapidjson')

local UserModel = Model:extend()
local User = UserModel:new("sqlite3", "/tmp/test.sqlite3")
print("------------------------ User:new")
p(User)

-- prepare db
User.db:run"DROP TABLE user"
User.db:run[[
  CREATE TABLE user(
    id  INT PRIMARY KEY,
    name  VARCHAR(50),
    email VARCHAR(50)
  )
]]
local list = {
	{ id=1, name="Jose das Couves", email="jose@couves.com", },
	{ id=2, name="Jack", email="manoel.joaquim@cafundo.com", },
	{ id=3, name="Jack", email="maria@dores.com", },
}

print("------------------------ User:save")
for i, p in pairs (list) do
	User:save({id=p.id, name=p.name, email=p.email})
end

print("------------------------ User:all")
p(User:all())

print("------------------------ User:find(1)")
p(User:find(1))
print("------------------------ User:find(4)")
p(User:find(4))

print("------------------------ User:where({name='Jack'})")
p(User:where({name='Jack'}))
print("------------------------ User:where(where({name='Jack',email='maria@dores.com'})")
p(User:where({name='Jack',email='maria@dores.com'}))

print("------------------------ User:update({name='Jack2'},{email='maria@dores.com'})")
p(User:update({name='Jack2'},{email='maria@dores.com'}))
print("------------------------ User:where({name='Jack2'})")
p(User:where({name='Jack2'}))

print("------------------------ User:destroy({id=2})")
p(User:destroy({id=2}))
print("------------------------ User:destroy({name='Jack2'})")
p(User:destroy({name='Jack2'}))
print("------------------------ User:all")
p(User:all())

app:get('/user/:id', function(params)
	local user = User:find(params.id)
	return JSON.encode(user)
end)
app:listen({port=8003})

print("Http Server listening at http://0.0.0.0:8003/user/:id")