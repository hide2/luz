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

function DB:select(statement, needcolumn)
	needcolumn = needcolumn and "a"
	local _rows = {}
	cur = self._conn:execute(statement)
	row = cur:fetch({}, needcolumn)
	while row do
		local r= row
		if #row == 1 then r = row[1] end
		table.insert(_rows, r)
		row = cur:fetch({}, needcolumn)
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
