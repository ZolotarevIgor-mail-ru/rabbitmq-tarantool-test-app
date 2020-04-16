local cartridge = require('cartridge')
local amqp = require("amqp")
local argparse = require("argparse")

local ctx = nil

local function consume_callback(body)
    local fiber = require('fiber')
    print(body)
    fiber.yield()
end

local function init(opts) -- luacheck: no unused args
    args = argparse.parse()

    ctx = amqp.new({
        role = "consumer",
        queue = args.queue,
        exchange = args.exchange,
        ssl = args.ssl,
        user = args.rabbitmq_user,
        password = args.rabbitmq_password,
        no_ack = false,
        callback = consume_callback
    })
    ctx:connect(args.host, args.port)    
    return true
end

local function stop()
    ctx:teardown()
    ctx = nil
end

local function consume() 
    local ok, err = ctx:consume()
end

return {
    role_name = 'app.roles.rabbitmq-consumer',
    init = init,
    stop = stop,
    utils = {
        consume = consume
    }
    -- dependencies = {'cartridge.roles.vshard-router'},
}
