local function readSettings(name, defaultValue) 
  if file.exists(name..".dat") then
    file.open(name..".dat","r+")
    value = file.read()
    file.close()
    return value
  else
    return defaultValue
  end
end

g_cycle = tonumber(readSettings("cycle", 30))
g_cycle_on = tonumber(readSettings("cycle_on", 10))
g_vent_speed = tonumber(readSettings("vent_speed", 1))
g_tmr_interval = tonumber(readSettings("interval", 60))
