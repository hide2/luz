local splitPath = require('pathjoin').splitPath
local DB = require('./db').DB
local Object = require('core').Object

local Model = Object:extend()

function Model:initialize(driver, ...)
	self.db = DB:new(driver, ...)
	local s = splitPath(debug.getinfo(3).source)
	local file = s[#s]
	local table = string.sub(file, 1, string.find(file, '.lua')-1)
	self.table = table
end

function Model:save(row)
	local ks = {}
	local vs = {}
	for k, v in pairs(row) do
		table.insert(ks, k)
		table.insert(vs, "'"..v.."'")
	end
	local sql = string.format("insert into %s(%s) values(%s)", self.table, table.concat(ks, ','), table.concat(vs, ','))
	p("[sql]", sql)
	return self.db:run(sql)
end
function Model:all()
	local sql = string.format("select * from %s", self.table)
	p("[sql]", sql)
	return self.db:select(sql, true)
end
function Model:find(id)
	local sql = string.format("select * from %s where id = %s", self.table, id)
	p("[sql]", sql)
	return self.db:select(sql, true)
end
function Model:where(wkv)
	local wkvs = {}
	for k, v in pairs(wkv) do
		table.insert(wkvs, k.."='"..v.."'")
	end
	local sql = string.format("select * from %s where %s", self.table, table.concat(wkvs, ' and '))
	p("[sql]", sql)
	return self.db:select(sql, true)
end
function Model:update(kv, wkv)
	local kvs = {}
	for k, v in pairs(kv) do
		table.insert(kvs, k.."='"..v.."'")
	end
	local wkvs = {}
	for k, v in pairs(wkv) do
		table.insert(wkvs, k.."='"..v.."'")
	end
	local sql = string.format("update %s set %s where %s", self.table, table.concat(kvs, ','), table.concat(wkvs, ' and '))
	p("[sql]", sql)
	return self.db:run(sql)
end
function Model:destroy(wkv)
	local wkvs = {}
	for k, v in pairs(wkv) do
		table.insert(wkvs, k.."='"..v.."'")
	end
	local sql = string.format("delete from %s where %s", self.table, table.concat(wkvs, ' and '))
	p("[sql]", sql)
	return self.db:run(sql)
end

return {
	Model = Model,
}