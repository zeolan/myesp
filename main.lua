g_cycle_started = false
g_cycle = nil
g_cycle_on = nil
g_vent_speed = nil
g_topic = nil
g_data = nil
m = nil

dofile("read_settings.lua")
dofile("sntp.lua")
dofile("wifi_register.lua")
dofile("relay_init.lua")
--dofile("relay_init.lua")
station_cfg={}
station_cfg.ssid="MikroTik-D9809F"
station_cfg.pwd="$Gadget2011"
station_cfg.save=true
wifi.setmode(wifi.STATION)
--local cfg = dofile("eus_params.lua")
wifi.sta.config(station_cfg)
--wifi.sta.connect()
--print(wifi.sta.getconfig())
--wifi.setmode(1)
--wifi.sta.connect()

-----------------------------------
function startMQTT()
    m = mqtt.Client("123", 120, "user1", "User1")

    m:connect("m23.cloudmqtt.com", 16312, false, function(client)
    print("mqtt client connected")

  -- subscribe topic with qos = 0
  client:subscribe("vent/+", 0, function(client) print("subscribe success") end)
  client:publish("user1", "hello", 0, 0, function(client) print("mqtt message sent") end)
end,
function(client, reason)
  print("failed reason: " .. reason)
end)
    m:on("message", function(client, topic, data)
        print(topic .. ":" )
        g_topic = topic
        g_data = data
        dofile("mqtt_process.lua")
        --process_mqtt(topic, data)
    end)
end
---------------------------------
-----------------------------------

g_myTimer = nill
srv = nill

function blinkLed(pin, delay, repeatTimes)
  local arrDelays = {}
  for i=1,repeatTimes*2 do
    arrDelays[i] = delay
  end
  gpio.mode(pin, gpio.OUTPUT)
  gpio.serout(pin, gpio.LOW, arrDelays, 1, function() end)
end

if apiKey ~= nil then
    apiKey = string.match(apiKey, "%s?([0-9%l%-]+)%s*")
end


if tmrInterval == nill then
  print ("--default setting")
  tmrInterval = 60
end

function saveSettings(name,value)
  file_name = name..".dat"
  file.remove(file_name)
  file.open(file_name,"w+")
  file.write(tostring(value))
  file.close()
end

function serverSetup()    
    srv = net.createServer()
    if srv then
        print("--server created")
        srv:listen(80,
           function(conn)
             --print("listen")
             conn:on("receive", receiver)
           end
        )
    end
    collectgarbage()
end

function receiver(sck, data)
    print(data)
    api_key = string.match(data, "apikey:%s?([0-9%l%-]+)(%s*)")
    local a, b, method, path, vars = string.find(data, "([A-Z]+) (.+)?(.+) HTTP")
    local restartServer = false
    if (method == nil) then
        _, _, method, path = string.find(data, "([A-Z]+) (.+) HTTP");
    end
    local PARAMS = {}
    local _ssid = nill
    local _pwd = nill
    if (vars ~= nil) and (method == "POST") and (api_key == apiKey) then
        --for k, v in string.gmatch(vars, "(%w+)=(%w+[-_]?%w+[-_]?%w+)&*") do
        for k, v in string.gmatch(vars, "(%w+)=(%w+)") do
            PARAMS[k] = v
        end
    end
    for k,v in pairs(PARAMS) do
        print (k.." : "..v)
        if k == "interval" then
            timerSetup(tonumber(v))
            saveSettings("interval", v)
        end
        if k == "setTalkBackID" then
            saveSettings("talkBackID", v)
        end
        if k == "setTalkBackKEY" then
            saveSettings("talkBackKEY", v)
        end
        if k == "ssid" then
            _ssid = v
        end
        if k == "pwd" then
            _pwd = v
        end
    end
    if _ssid ~= nill and _pwd ~= nill then
        local config = {}
        config.ssid = _ssid
        config.pwd = _pwd
        config.save = true
        --wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
        --wifi.sta.disconnect()
        --srv.close()
        --wifi.sta.config(config)
        restartServer = true
    end
    local buf = "HTTP/1.1 200 OK\r\nContent-type: text/html\r\n\r\n"
    buf = buf.."<h1> ESP8266 Setup Page</h1>"
    buf = buf.."<div>TO SET SSID AND PASSWORD OF WIFI: esp8266_ip_adress/?ssid=YOUR_SSID&pwd=YOUR_PASSWORD</div><br>"
    buf = buf.."<div>TO SET INTERVAL: esp8266_ip_adress/?setTimer=TIMER_INTERVAL_IN_SECONDS</div><br>"
    buf = buf.."<span>Period&nbsp<input type='text' value='"..tmrInterval.."' size='4'>&nbsp</span>seconds<br><br>"
    buf = buf.."<span>API Key&nbsp<input type='text' value='"..apiKey.."' size='32'></span>"
    sck:send(buf, function() sck:close() if restartServer == true then
        restartServer = false
        local config = {}
        config.ssid = _ssid
        config.pwd = _pwd
        config.save = true
        wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
        wifi.sta.disconnect()
        wifi.sta.config(config)
        node.restart()
        end
    end)
end
