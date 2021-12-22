print("Settings +++")
local function readSettings(name, defaultValue) 
  if file.exists(name..".dat") then
    file.open(name..".dat","r+")
    value = file.read()
    file.close()
    print(string.format("%s = %d", name, value))
    return value
  else
    return defaultValue
  end
end

g_cycle = tonumber(readSettings("g_cycle", 30))
g_cycle_on = tonumber(readSettings("g_cycle_on", 10))
g_vent_speed = tonumber(readSettings("vent_speed", 1))
g_tmr_interval = tonumber(readSettings("interval", 60))
g_t_min = tonumber(readSettings("g_t_min", 100))
g_t_max = tonumber(readSettings("g_t_max", 250))
print("Settings ---")
