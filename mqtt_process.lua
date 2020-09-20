local K1 = 8
local K2 = 7
local K3 = 6
local K4 = 5
local H = 2

function set_speed(data)
    if data ~= nil then
        --print(data)
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
        send_status("SPEED->"..tostring(data))
    end
end

function set_heater(data)
    --print(data)
    if data == "0" then
        gpio.write(H, gpio.LOW)
    elseif data == "1" then
        gpio.write(H, gpio.HIGH)
    end
    send_status("HEATER->"..tostring(data))
end

function set_cycle_on(data)
    --print(data)
    g_cycle_on = tonumber(data)
    if g_cycle_on <= g_cycle then
        saveSettings("cycle_on", g_cycle_on)
        send_status("CYCLE->"..tostring(data))
    else
        send_status("fail:g_cycle_on > g_cycle")
    end
end

function process_mqtt(topic, data)
    local sub_topic = string.match(topic, "/([%w_]+)")
    if sub_topic == "speed" then
        set_speed(data)
    elseif sub_topic == "heat" then
        set_heater(data)
    elseif sub_topic == "cycle_on" then
        set_cycle_on(data)
    end
    print(g_topic..": "..g_data)
end

process_mqtt(g_topic, g_data)
