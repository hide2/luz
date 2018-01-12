local Object = require('core').Object

local DB = Object:extend()

function DB:initialize(driver, ...)
	self._driver = driver or self._driver
	self._options = ... or self._options
	if self._driver == 'sqlite3' then
		self._env = require("luasql.sqlite3").sqlite3()
	elseif self._driver == 'postgres' then
		self._env = require("luasql.postgres").postgres()
	elseif self._driver == 'mysql' then
		self._env = require("luasql.mysql").mysql()
	end
	if self._env then
		self._conn = self._env:connect(...)
	end
end

local function rows(connection, sql_statement)
	local cursor = assert (connection:execute(sql_statement))
	return function ()
		return cursor:fetch()
	end
end
function DB:select(...)
	local _rows = {}
	while true do
		local r = {rows(self._conn, ...)}
		if #r == 0 then break end
		if #r == 1 then r = r[1] end
		table.insert(_rows, r)
	end
	if #_rows == 0 then
		return nil
	elseif #_rows == 1 then
		return _rows[1]
	else
		return _rows
	end
end

function DB:run(...)
	return self._conn:execute(...)
end


function DB:commit(...)
	self._conn:commit(...)
end

function DB:rollback(...)
	self._conn:rollback(...)
end

function DB:setautocommit(...)
	self._conn:setautocommit(...)
end

function DB:close()
	self._conn:close()
	self._env:close()
end

return {
	DB = DB,
}
