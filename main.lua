wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,function (T)
    print ("\n\rGOT IP "..T.IP)
    --blinkLed(2)
    serverSetup()
    sendData()
    timerSetup(tmrInterval)
end)

myTimer = nill
srv = nill

function blinkLed(pin, delay, repeatTimes)
  local arrDelays = {}
  for i=1,repeatTimes*2 do
    arrDelays[i] = delay
  end
  gpio.mode(pin, gpio.OUTPUT)
  gpio.serout(pin, gpio.LOW, arrDelays, 1, function() end)
end

function readSettings(name)
  if file.exists(name) then
    file.open(name,"r+")
    value = file.read()
    file.close()
    return value
  end
end

tmrInterval = readSettings("interval")

if tmrInterval == nill then
  print ("default setting")
  tmrInterval = 60
end

function sendData()
  local status, temp, humi, temp_dec, humi_dec = dht.read11(2)
  local url = "http://api.thingspeak.com/update?api_key=QRH3VY7R3GM17ERN\&field1="
  url = url..temp
  url = url.."\&field2="..humi
  http.get(url, nill, function() print("sent") end)
  blinkLed(4, 100000, 2)
end

function saveSettings(name,value)
  file.remove(name)
  file.open(name,"w+")
  file.writeline(value)
  file.close()
end

function timerSetup(interval)
    if myTimer ~= nill then
        myTimer:stop()
        myTimer:interval(interval*1000)
        myTimer:start()
        print ("timer changed")
    else
        myTimer = tmr.create()
        myTimer:register(interval*1000, tmr.ALARM_AUTO, sendData);
        myTimer:start()
    end
end

function serverSetup()    
    srv = net.createServer()
    if srv then
        print(" server created")
        srv:listen(80,
           function(conn)
             print("listen")
             conn:on("receive", receiver)
           end
        )
    end
    collectgarbage()
end

function receiver(sck, data)
    print(data)
    local _, _, method, path, vars = string.find(data, "([A-Z]+) (.+)?(.+) HTTP");
    local restartServer = false
        if (method == nil) then
            _, _, method, path = string.find(data, "([A-Z]+) (.+) HTTP");
        end
        local GET = {}
        local _ssid = nill
        local _pwd = nill
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+[-_]?%w+[-_]?%w+)&*") do
                GET[k] = v
            end
        end
        for k,v in pairs(GET) do
            print (k.." : "..v)
            if k == "setTimer" then
                timerSetup(tonumber(v))
                saveSettings("interval", v)
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
    buf = buf.."<span>Period<input type='text' value='"..tmrInterval.."' size='4'></span>in seconds<a href='\?setTimer'><button>Set timer</button>"
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

