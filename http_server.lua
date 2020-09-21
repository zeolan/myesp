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
