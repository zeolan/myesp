ow_pin = 4 -- gpio0 = 3, gpio2 = 4

function readout(temp)
  --if t.sens then
    --print("Total number of DS18B20 sensors: ".. #t.sens)
    --for i, s in ipairs(t.sens) do
    --  print(string.format("  sensor #%d address: %s%s",  i, ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(s:byte(1,8)), s:byte(9) == 1 and " (parasite)" or ""))
    --end
  --end
  if next(temp) == nil then
    print("empty table")
    print("turn OFF Heater")
    set_heater(0)
    send_status("HEATER->OFF")
    return
  end

  for addr, temp in pairs(temp) do
    local s = string.gsub(temp, "%.", "")
    local t = tonumber(s)
    if t < g_t_max then
        print("less MAX")
    else
        print("more or equal MAX")
        print("turn OFF Heater")
        set_heater(0)
        send_status("HEATER->OFF")
    end
    if t < g_t_min then
        print("less MIN")
        if g_cycle_started or g_vent_mode == 1 then
            set_heater(1)
            send_status("HEATER->ON")
            print("turn ON Heater")
        end
    else
        print("more or equal MIN")
    end
    t_str = string.format("%s.%s", s:sub(-3, -2), s:sub(-1))
    if m ~= nil then
        m:publish("vent/temperature", t_str, 0, 0, nil)
    end
    print(string.format("Sensor %s: %s °C", ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8)), temp))
  end
end
