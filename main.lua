g_cycle_started = false
g_on_off = 0
g_cycle = nil
g_cycle_on = nil
g_vent_mode = 0
g_vent_speed = nil
g_topic = nil
g_data = nil
g_tmr_interval = nil
g_t_max = 300
g_t_min = 250

g_myTimer = nil
--myTimer = nil

m = nil
t = require("ds18b20")

gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.LOW)

function timerSetup(interval)
    if g_myTimer ~= nil then
        g_myTimer:stop()
        g_myTimer:interval(interval*1000)
        g_myTimer:start()
        g_tmr_interval = interval
        print("--timer changed")
    else
        g_myTimer = tmr.create()
        g_myTimer:register(interval*1000, tmr.ALARM_AUTO, sntp_sync);
        g_myTimer:start()
        print("--timer started with interval "..interval)
    end
end

dofile("read_settings.lua")
dofile("ds18b20_example.lua")
dofile("sntp.lua")
dofile("wifi_register.lua")
--t:read_temp(readout, ow_pin, t.C)
dofile("relay_init.lua")
dofile("mqtt_process.lua")

station_cfg={}
station_cfg.ssid="MikroTik-D9809F"
station_cfg.pwd="$Gadget2011"
station_cfg.save=true
wifi.setmode(wifi.STATION)
--local cfg = dofile("eus_params.lua")
--wifi.sta.config(station_cfg)
--wifi.sta.connect()
--print(wifi.sta.getconfig())

--wifi.setmode(1)
--wifi.sta.connect()

-----------------------------------
function send_status(status)
    m:publish("vent/status", status, 1, 0, nil)
end

function startMQTT()
    m = mqtt.Client("123", 120, "user1", "User1")

    m:connect("m23.cloudmqtt.com", 16312, false, function(client)
    print("mqtt client connected")

  -- subscribe topic with qos = 0
  client:subscribe("vent/+", 0,
      function(client)
        print("subscribe success")
        gpio.write(4, gpio.HIGH)
        send_status("READY")
        client:publish("vent/cycle_on", g_cycle_on, 0, 0, nil)
        client:publish("vent/speed", g_vent_speed, 0, 0, nil)
        client:publish("vent/on_off", g_on_off, 0, 0, nil)
        client:publish("vent/mode", g_vent_mode, 0, 0, nil)
        client:publish("vent/heat", 0, 0, 0, nil)
      end
  )
end,
function(client, reason)
  print("failed reason: " .. reason)
end)
    m:on("message", function(client, topic, data)
        g_topic = topic
        g_data = data
        process_mqtt(topic, data)
    end)
end
------------------

function blinkLed(pin, delay, repeatTimes)
  local arrDelays = {}
  for i=1,repeatTimes*2 do
    arrDelays[i] = delay
  end
  gpio.mode(pin, gpio.OUTPUT)
  gpio.serout(pin, gpio.LOW, arrDelays, 1, function() end)
end

function saveSettings(name,value)
  file_name = name..".dat"
  file.remove(file_name)
  file.open(file_name,"w+")
  file.write(tostring(value))
  file.close()
end
