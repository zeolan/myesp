myTimer = nill

local savedAP = wifi.sta.getapinfo()

function listap(t)
    for k,v in pairs(t) do
        for kk, vv in pairs(savedAP) do
            if type(vv) == "table" then
                for kkk, vvv in pairs(vv) do
                    if vvv == k then
                        vv.auto = true
                        vv.save = true
                        wifi.sta.config(vv)
                        wifi.sta.connect()
                        collectgarbage()
                        break
                    end
                end
            end
        end
    end
end

function connectToAp(ap)
    local config = {}
    config.ssid = ap.ssid

end

wifi.sta.getap(listap)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,function (T)
    print ("\n\rGOT IP "..T.IP)
    sntp.sync(nil, sntpSuccess, nil, false)
    timerSetup(2)
    getCommands()
    --blinkLed(2)
    --serverSetup()
    --sendData()
    --timerSetup(tmrInterval)
end)

function sntpSuccess(s, us, server, info)
    local t = rtctime.epoch2cal(s)
    local dateTime = ""..t.year.." "..t.day.." "..t.mon.." "..t.hour..":"..t.min
    print ("Current Time is "..dateTime)
    collectgarbage()
    --tm = rtctime.epoch2cal(rtctime.get())
    --print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
end

function getCommands()
    local url = "http://api.thingspeak.com/talkbacks/21142/commands.json?api_key=T5EEURWKXI0KKHG8"
    http.get(url, nil, getCommandsSuccess)
end

function getCommandsSuccess(code, data)
    data = string.gsub(data, ":(%s*)null,",":\"sjson.NULL\",")
    local commandTable = sjson.decode(data)
    for n, command in pairs(commandTable) do
        print ("command "..n)
        cmd, value = parseCommand(command["command_string"])
        if cmd == "setledon" then setLed(value, 0) end
        if cmd == "setledoff" then setLed(value, 1) end
        executeCommand(command["command_string"])
        print (parseCommand(command["command_string"]))
    end
    collectgarbage()
end

function setLed(pin, value)
  if pin ~= "" then
    gpio.mode(pin, gpio.OUTPUT)
    gpio.write(pin, value)
  end
end

function timerSetup(interval)
    if myTimer ~= nill then
        myTimer:stop()
        myTimer:interval(interval*1000)
        myTimer:start()
        print ("timer changed")
    else
        myTimer = tmr.create()
        myTimer:register(interval*1000, tmr.ALARM_AUTO, getCommands);
        myTimer:start()
    end
end

function parseCommand(commandString)
    _, _, k, v = string.find(commandString, "(%w+)%s*=%s*(%w*)")
    return k,v
end

function executeCommand(cmd)
    local url = "http://api.thingspeak.com/talkbacks/21142/commands/execute.json?api_key=T5EEURWKXI0KKHG8"
    local tm = rtctime.epoch2cal(rtctime.get())
    http.get(url, nil, function() print (string.format("Command '%s' executed at %04d/%02d/%02d %02d:%02d",
                                         cmd, tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"])) end)
end
