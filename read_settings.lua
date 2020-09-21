local function readSettings(name, defaultValue) 
  if file.exists(name..".dat") then
    file.open(name..".dat","r+")
    value = file.read()
    file.close()
    print(name,value)
    return value
  else
    return defaultValue
  end
end

print("Settings:")
print("Name","Value")
g_cycle = tonumber(readSettings("cycle", 30))
g_cycle_on = tonumber(readSettings("cycle_on", 10))
g_vent_speed = tonumber(readSettings("vent_speed", 1))
g_tmr_interval = tonumber(readSettings("interval", 60))
--thingSpeakKEY = readSettings("thingSpeakKEY", nil)
--talkBackID = readSettings("talkBackID", nil)
--talkBackKEY = readSettings("talkBackKEY", nil)
--apiKey = readSettings("api_key", nil)
