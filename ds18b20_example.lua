ow_pin = 4 -- gpio0 = 3, gpio2 = 4

ds_in_addr = 172
ds_out_addr = 178

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

  local t_str = ""
  for addr, temp in pairs(temp) do
    ds_addr = addr:byte(8,8)
    local s = string.gsub(temp, "%.", "")
    local t = tonumber(s)
    local t_out = nil
    if ds_addr == ds_out_addr then
        t_out = t
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
                if g_heat_cycle % 2 == 0 then
                    set_heater(1)
                    send_status("HEATER->1 Cycle")
                    print("turn ON Heater")
                else
                    set_heater(1)
                    send_status("HEATER->0 Cycle")
                    print("turn OFF Heater")
                end
                --g_heat_cycle = 0
            end
        else
            print("more or equal MIN")
        end
    end
    if t_str == "" then
        t_str = t_str .. (string.format("%s.%s", s:sub(-3, -2), s:sub(-1)) .. "/")
    else
        t_str = t_str .. string.format("%s.%s", s:sub(-3, -2), s:sub(-1))
    end
    print(string.format("Sensor %s: %s °C", ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8)), temp))
  end
  if m ~= nil then
    m:publish("vent/temperature", t_str, 0, 0, nil)
  end
end
