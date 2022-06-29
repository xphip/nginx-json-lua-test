ngx.header.content_type = 'application/json'

local json = require("json")

local decoded = json.decode('[1,2,3,{"x":10}]')
local encoded = json.encode(decoded)

ngx.say(encoded)