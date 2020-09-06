local myTimer = nill

function timerSetup(interval)
    if myTimer ~= nill then
        myTimer:stop()
        myTimer:interval(interval*1000)
        myTimer:start()
        tmrInterval = interval
        print("--timer changed")
    else
        myTimer = tmr.create()
        myTimer:register(interval*1000, tmr.ALARM_AUTO, sntp_sync);
        myTimer:start()
        print("--timer started with interval "..interval)
    end
end

function sntp_sync()
    sntp.sync("ua.pool.ntp.org",
      function(sec, usec, server, info)
        --print('sync', sec, usec, server)
        tm = rtctime.epoch2cal(sec)
        if not g_cycle_started and tm["min"]%g_cycle == 0 then
            g_cycle_started = true
            print("=== start cycle")
            print(string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
        end
        if g_cycle_started and tm["min"]%g_cycle >= g_cycle_on then
            g_cycle_started = false
            print("=== end cycle")
            print(string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
        end
        --print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
        --dofile("ds18b20_example.lua")
      end,
      function(reason)
       print('sntp sync failed, reason:'..reason)
      end
    )
end