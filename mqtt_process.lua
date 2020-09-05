local K1 = 8
local K2 = 7
local K3 = 6
local K4 = 5

local function set_speed(data)
    if data ~= nil then
        print(data)
        if data == "0" then
            gpio.write(K1, gpio.LOW)
            gpio.write(K2, gpio.LOW)
            gpio.write(K3, gpio.LOW)
            gpio.write(K4, gpio.LOW)
        end
        if data == "1" then
            gpio.write(K1, gpio.HIGH)
            gpio.write(K2, gpio.LOW)
            gpio.write(K3, gpio.LOW)
            gpio.write(K4, gpio.LOW)
        end
        if data == "2" then
            gpio.write(K2, gpio.HIGH)
            gpio.write(K1, gpio.LOW)
            gpio.write(K3, gpio.LOW)
            gpio.write(K4, gpio.LOW)
        end
        if data == "3" then
            gpio.write(K3, gpio.HIGH)
            gpio.write(K1, gpio.LOW)
            gpio.write(K2, gpio.LOW)
            gpio.write(K4, gpio.LOW)
        end
        if data == "4" then
            gpio.write(K4, gpio.HIGH)
            gpio.write(K1, gpio.LOW)
            gpio.write(K2, gpio.LOW)
            gpio.write(K3, gpio.LOW)
        end
    end
end

local function set_heater(data)

end

local function process_mqtt(topic, data)
    local sub_topic = string.match(topic, "/(%w+)")
    if sub_topic == "speed" then
        set_speed(data)
    elseif sub_topic == "heater" then
        set_heater(data)
    end
end

process_mqtt(g_topic, g_data)