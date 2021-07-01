local K1 = 8
local K2 = 7
local K3 = 6
local K4 = 5
local H = 2

function get_status(sub_topic, data)
    status = nil
    if sub_topic ~= nill and data ~= nill then
        if sub_topic == "mode" then
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
        elseif sub_topic == "servo" then

        end
    end
    return status
end 

function set_mode(data)
    if data ~= nil then
        g_vent_mode = tonumber(data)
        if g_vent_mode == MODE_OFF then
            g_cycle_started = false
            set_speed(0)
            m:publish("vent/servo", 0, 0, 0, nil)
            m:publish("vent/heat", 0, 0, 0, nil)
        elseif g_vent_mode == MODE_ON then
            g_cnt = 0
            if g_vent_speed == 0 then
                m:publish("vent/heat", 0, 0, 0, nil)
                m:publish("vent/servo", 0, 0, 0, nil)
            else
                m:publish("vent/servo", 1, 0, 0, nil)
            end
            set_speed(g_vent_speed)
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
        else
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
end

function set_heater(data)
    if data == 0 then
        gpio.write(H, gpio.LOW)
    elseif data == 1 then
        gpio.write(H, gpio.HIGH)
    end
end

function set_cycle_on(data)
    if tonumber(data) <= g_cycle then
        g_cycle_on = tonumber(data)
        saveSettings("g_cycle_on", g_cycle_on)
        send_status("OK: g_cycle_on changed to "..g_cycle_on)
    else
        send_status("Err: g_cycle_on > "..g_cycle)
        m:publish("vent/cycle_on", g_cycle_on, 0, 0, nil)
    end
end

function set_servo(data)
    if data == 0 then
        servo_timer_start(servo_close)
    elseif data == 1 then
        servo_timer_start(servo_open)
    end
end

function process_mqtt(topic, data)
    local sub_topic = string.match(topic, "/([%w_]+)")
    if data ~= nil then
        if sub_topic == "mode" then
            g_vent_mode = tonumber(data)
            set_mode(g_vent_mode)
        elseif sub_topic == "speed" then
            g_vent_speed = tonumber(data)
            if g_cycle_started or g_vent_mode == MODE_ON then
                set_speed(g_vent_speed)
            end
        elseif sub_topic == "heat" then
            if g_cycle_started or g_vent_mode == MODE_ON then
                --set_heater(tonumber(data))
            end
        elseif sub_topic == "cycle_on" then
            set_cycle_on(data)
        elseif sub_topic == "servo" then
            g_servo_mode = tonumber(data)
            if g_servo_mode == 0 then
                set_speed(0)
                m:publish("vent/heat", 0, 0, 0, nil)
            end
            set_servo(g_servo_mode)
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
