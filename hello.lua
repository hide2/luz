local app = require("./luz/app").app:new()

app:get('/', function()
	return "hello"
end);
app:listen({port=8001}, onRequest)

print("Http Server listening at http://0.0.0.0:8001/")