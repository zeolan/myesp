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
    if (vars ~= nil) then --and (method == "POST") then
        for k, v in string.gmatch(vars, "(%w+[-_]?%w+[-_]?%w+)=(%d+)") do
        --for k, v in string.gmatch(vars, "(%w+)=(%w+)") do
            if k == 'reset' then
                node.restart()
            else
                saveSettings(k, v)
            end
        end
    end
    --for k,v in pairs(PARAMS) do
    --    saveSettings(k, v)
    --end

    local buf = "HTTP/1.1 200 OK\r\nContent-type: text/html\r\n\r\n"
    buf = buf.."<h1> Vent Setup Page</h1>"
    buf = buf.."<div> Usage: 192.168.88.xxx/?g_t_min=100</div><br>"
    buf = buf.."<div> Available options: g_t_min, g_t_max, g_cycle, g_cycle_on</div><br>"
    --buf = buf.."<div>TO SET INTERVAL: esp8266_ip_adress/?setTimer=TIMER_INTERVAL_IN_SECONDS</div><br>"
    --buf = buf.."<span>Period&nbsp<input type='text' value='"..g_tmr_interval.."' size='4'>&nbsp</span>seconds<br><br>"
    --buf = buf.."<span>API Key&nbsp<input type='text' value='"..apiKey.."' size='32'></span>"
    sck:send(buf,
        function()
            sck:close()
        end
    )
    collectgarbage()
end
