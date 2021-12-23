ow_pin = 4 -- gpio0 = 3, gpio2 = 4

readout = (function (temp)
    local ds_in_addr = 172
    --172
    local ds_out_addr = 127
    --178
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

  --local t_str = ""
  local t_out = "222"
  local t_in = "-115"
  for addr, temp in pairs(temp) do
    local ds_addr = addr:byte(8,8)
    print(temp)
    local s = string.gsub(temp, "%.", "")
    --print(s)
    --local t = tonumber(s)
    --local t_s = nil
    if ds_addr == ds_out_addr then
        t_out = s
    elseif ds_addr == ds_in_addr then
        t_in = s
    end
    --t_s = string.format("%s.%s", s:sub(-3, -2), s:sub(-1))
    --if t_str == "" then
    --    t_str = t_s .. "/"
    --else
    --    t_str = t_str .. t_s
    --end
    --print(string.format("Sensor %s: %s °C", ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8)), temp))
  end
  print(t_in)
  print(t_out)
  local t_in_adj = t_in
  if t_in:len() > 4 then
    t_in_adj = t_in:sub(0, -3)
  end
  local t_str = string.format("%s.%s", t_out:sub(-3, -2), t_out:sub(-1)).. "/"..string.format("%s.%s", t_in_adj:sub(-3, -2), t_in_adj:sub(-1))
  t_out = tonumber(t_out)
  t_in = tonumber(t_in)
  if t_out > g_t_max then
      set_heater(0)
      send_status("T>Max -> OFF")
  --elseif t < g_t_min then
      --print("less MIN")
      --if g_cycle_started or g_vent_mode == MODE_ON then
      --    if g_heat_cycle % 2 == 0 then
      --        set_heater(1)
      --        send_status("T<Min -> ON")
      --    else
      --        set_heater(0)
      --        send_status("T<Min -> OFF")
      --    end
      --    --g_heat_cycle = 0
      --end
  else
    if t_in < g_t_min and (g_cycle_started or g_vent_mode == MODE_ON) then
      if t_out ~= nil and t_out < g_t_max then
        if g_heat_cycle % 2 == 0 then
          set_heater(1)
          send_status("T<Min -> ON")
        else
            set_heater(0)
            send_status("T<Min -> OFF")
        end
      end
    end
    --send_status("TEMP OK")
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
