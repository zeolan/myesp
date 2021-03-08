ow_pin = 4 -- gpio0 = 3, gpio2 = 4

readout = (function (temp)
    local ds_in_addr = 172
    local ds_out_addr = 178
    --if t.sens then
        --print("Total number of DS18B20 sensors: ".. #t.sens)
  --  for i, s in ipairs(t.sens) do
  --    print(string.format("  sensor #%d address: %s%s",  i, ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(s:byte(1,8)), s:byte(9) == 1 and " (parasite)" or ""))
  --  end
    --end
  if next(temp) == nil then
    set_heater(0)
    send_status("NO DS FOUND")
    return
  end

  local t_str = ""
  for addr, temp in pairs(temp) do
    local ds_addr = addr:byte(8,8)
    local s = string.gsub(temp, "%.", "")
    local t = tonumber(s)
    local t_out = nil
    local t_in = nil
    local t_s = nil
    if ds_addr == ds_out_addr then
        t_out = t
        if t > g_t_max then
            set_heater(0)
            send_status("T>Max -> OFF")
        elseif t < g_t_min then
            --print("less MIN")
            if g_cycle_started or g_vent_mode == MODE_ON then
                if g_heat_cycle % 2 == 0 then
                    set_heater(1)
                    send_status("T<Min -> ON")
                else
                    set_heater(0)
                    send_status("T<Min -> OFF")
                end
                --g_heat_cycle = 0
            end
        else
            send_status("TEMP OK")
        end
    else
        t_in = t
    end
    t_s = string.format("%s.%s", s:sub(-3, -2), s:sub(-1))
    if t_str == "" then
        t_str = t_s .. "/"
    else
        t_str = t_str .. t_s
    end
    --print(string.format("Sensor %s: %s °C", ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8)), temp))
  end
  if m ~= nil then
      if g_mqtt_connected then
        m:publish("vent/temperature", t_str, 0, 0, nil)
      else
          print("====> cann't publish")
          node.restart()
      end
  end
  --collectgarbage("collect")
end)
