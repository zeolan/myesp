myTimer = nill

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,function (T)
    print ("\n\rGOT IP "..T.IP)
    sntp.sync(nil, sntpSuccess, nil, false)
    timerSetup(5)
    getCommands()
    --blinkLed(2)
    --serverSetup()
    --sendData()
    --timerSetup(tmrInterval)
end)

function sntpSuccess(s, us, server, info)
    --print (s)
    --print (us)
    --print (server)
    --print (info)
    --for k, v in pairs(info) do
    --    print ("k = "..k)
    --    print ("v = "..v)
    --end
    local t = rtctime.epoch2cal(s)
    local dateTime = ""..t.year.." "..t.day.." "..t.mon.." "..t.hour..":"..t.min
    print ("Current Time is "..dateTime)
    --tm = rtctime.epoch2cal(rtctime.get())
    --print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
end

function getCommands()
    local url = "http://api.thingspeak.com/talkbacks/21142/commands.json?api_key=T5EEURWKXI0KKHG8"
    http.get(url, nil, getCommandsSuccess)
end

function getCommandsSuccess(code, data)
    print(code, data, "\n\r")
    --print (sjson.decode(data)[0])
    --local d = '{"id":10601519,"command_string":"setledon","position":1,"executed_at":null,"created_at":"2018-01-01T20:03:51Z"}'
    data = string.gsub(data, ":(%s*)null,",":\"sjson.NULL\",")
    print (data)
    local commandTable = sjson.decode(data)
    --d:gsub("null","sjson.NULL")
    for n, command in pairs(commandTable) do
        print ("command "..n)
        print (parseCommand(command["command_string"]))
        for k, v in pairs(command) do
            --print ("k = "..k)
            --if v == "sjson.NULL" then v = "" end
            --print ("v = "..v)
        end
    end
    --local firstCommand = commandTable[1]["command_string"]
    --print (parseCommand(firstCommand))
end

function setLed(pin, value)
  gpio.mode(pin, gpio.OUTPUT)
  gpio.write(pin, value)
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
    _, _, k, v = string.find(commandString, "(%w+)%s*=%s*(%w+)")
    return k,v
end

function executeCommand()
    local url = "http://api.thingspeak.com/talkbacks/21142/commands/execute.json?api_key=T5EEURWKXI0KKHG8"
    http.get(url)
end
