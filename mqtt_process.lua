local K1 = 8
local K2 = 7
local K3 = 6
local K4 = 5
local H = 2

function get_status(sub_topic, data)
    status = nil
    if sub_topic ~= nill and data ~= nill then
        if sub_topic == "on_off" then
            if tonumber(data) == 0 then
                status = "OFF"
            elseif tonumber(data) == 1 and g_cycle_started then
                status = "ON"
            end
        elseif sub_topic == "mode" then
            if tonumber(data) == 0 then
                status = "OFF"
            elseif tonumber(data) == 1 then
                status = "ON"
            elseif tonumber(data) == 2 then
                if g_cycle_started == 1 then
                    status = "AUTO->ON"
                else
                    status = "AUTO->OFF"
                end
            end
        end
    end
    return status
end 

function set_mode(data)
    if data ~= nil then
        g_vent_mode = tonumber(data)
        if g_vent_mode == 0 then
            g_cycle_started = false
            set_speed(0)
        elseif g_vent_mode == 1 then
            set_speed(g_vent_speed)
        end
    end
end

function set_on_off(data)
    if data ~= nil then
        g_on_off = tonumber(data)
        if g_on_off == 0 then
            g_cycle_started = false
            set_speed(0)
        end
    end
end

function set_speed(data)
    if data ~= nil then
        if data == 0 then
            gpio.write(K1, gpio.LOW)
            gpio.write(K2, gpio.LOW)
            gpio.write(K3, gpio.LOW)
            gpio.write(K4, gpio.LOW)
            gpio.write(H, gpio.LOW)
            m:publish("vent/heat", 0, 0, 0, nil)
        end
        if data == 1 then
            gpio.write(K1, gpio.HIGH)
            gpio.write(K2, gpio.LOW)
            gpio.write(K3, gpio.LOW)
            gpio.write(K4, gpio.LOW)
        end
        if data == 2 then
            gpio.write(K2, gpio.HIGH)
            gpio.write(K1, gpio.LOW)
            gpio.write(K3, gpio.LOW)
            gpio.write(K4, gpio.LOW)
        end
        if data == 3 then
            gpio.write(K3, gpio.HIGH)
            gpio.write(K1, gpio.LOW)
            gpio.write(K2, gpio.LOW)
            gpio.write(K4, gpio.LOW)
        end
        if data == 4 then
            gpio.write(K4, gpio.HIGH)
            gpio.write(K1, gpio.LOW)
            gpio.write(K2, gpio.LOW)
            gpio.write(K3, gpio.LOW)
        end
    end
end

function set_heater(data)
    if data == 0 then
        gpio.write(H, gpio.LOW)
    elseif data == 1 then
        gpio.write(H, gpio.HIGH)
    end
end

function set_cycle_on(data)
    g_cycle_on = tonumber(data)
    if g_cycle_on <= g_cycle then
        saveSettings("cycle_on", g_cycle_on)
    end
end

function process_mqtt(topic, data)
    local sub_topic = string.match(topic, "/([%w_]+)")
    if data ~= nil then
        if sub_topic == "on_off" then
            set_on_off(data)
        elseif sub_topic == "mode" then
            g_vent_mode = tonumber(data)
            set_mode(g_vent_mode)
        elseif sub_topic == "speed" then
            g_vent_speed = tonumber(data)
            if g_cycle_started or g_vent_mode == 1 then
                set_speed(g_vent_speed)
            end
        elseif sub_topic == "heat" then
            if g_cycle_started or g_vent_mode == 1 then
                set_heater(tonumber(data))
            end
        elseif sub_topic == "cycle_on" then
            set_cycle_on(data)
        end
        if sub_topic ~= "status" then
            status = get_status(sub_topic, data)
            if status ~= nil then
                send_status(status)
            end
        end
        print(g_topic..": "..data)
    end
end
