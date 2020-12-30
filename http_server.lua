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
end

function receiver(sck, data)
    print("received: "..data)
    local _, _, method, _, vars = string.find(data, "([A-Z]+) (.+)?(.+) HTTP")
    --local restartServer = false
    if (method == nil) then
        _, _, method, path = string.find(data, "([A-Z]+) (.+) HTTP");
    end
    --local PARAMS = {}
    --local _ssid = nill
    --local _pwd = nill
    if (vars ~= nil) and (method == "POST") then
        --for k, v in string.gmatch(vars, "(%w+)=(%w+[-_]?%w+[-_]?%w+)&*") do
        for k, v in string.gmatch(vars, "(%w+)=(%w+)") do
            --PARAMS[k] = v
            saveSettings(k, v)
        end
    end
    --for k,v in pairs(PARAMS) do
    --    saveSettings(k, v)
    --end

    local buf = "HTTP/1.1 200 OK\r\nContent-type: text/html\r\n\r\n"
    buf = buf.."<h1> ESP8266 Setup Page</h1>"
    --buf = buf.."<div>TO SET SSID AND PASSWORD OF WIFI: esp8266_ip_adress/?ssid=YOUR_SSID&pwd=YOUR_PASSWORD</div><br>"
    --buf = buf.."<div>TO SET INTERVAL: esp8266_ip_adress/?setTimer=TIMER_INTERVAL_IN_SECONDS</div><br>"
    buf = buf.."<span>Period&nbsp<input type='text' value='"..g_tmr_interval.."' size='4'>&nbsp</span>seconds<br><br>"
    --buf = buf.."<span>API Key&nbsp<input type='text' value='"..apiKey.."' size='32'></span>"
    sck:send(buf,
        function()
            sck:close()
        end
    )
    collectgarbage()
end
