local app = require("./luz/app").app:new()
local JSON = require('rapidjson')

app:get('/echo/:msg', function(params)
	return JSON.encode({ msg = params.msg})
end)
app:listen({port=8002})

print("Http Server listening at http://0.0.0.0:8002/echo/:msg")