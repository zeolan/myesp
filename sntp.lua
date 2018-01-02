wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,function (T)
    print ("\n\rGOT IP "..T.IP)
    sntp.sync(nil, sntpSuccess, nil, false)
    getCommands()
end)

function sntpSuccess(s, us, server, info)
    print (s)
    print (us)
    print (server)
    print (info)
    for k, v in pairs(info) do
        print ("k = "..k)
        print ("v = "..v)
    end
    --year, mon, day, hour, min = rtctime.epoch2cal(s)
    --local dateTime = ""..year.." "..day.." "..mon.." "..hour..":"..min
    --print ("Current Time is "..dateTime)
end
