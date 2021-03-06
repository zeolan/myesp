function sntp_sync()
    --dofile("ds18b20_example.lua")
    sntp.sync("ua.pool.ntp.org",
      function(sec, usec, server, info)
        tm = rtctime.epoch2cal(sec)
        if g_vent_mode == 2 and not g_cycle_started and tm["min"]%g_cycle == 0 then
            g_cycle_started = true
            print("=== start cycle")
            print(string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
            send_status("AUTO->ON")
            m:publish("vent/speed", g_vent_speed, 0, 0, nil)
        end
        if g_cycle_started and tm["min"]%g_cycle >= g_cycle_on then
            g_cycle_started = false
            print("=== end cycle")
            print(string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
            if g_vent_mode == 2 then
                set_speed(0)
                set_heater(0)
                send_status("AUTO->OFF")
            end
        end
        --print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
        --dofile("ds18b20_example.lua")
        --t:read_temp(readout, ow_pin, t.C)
      end,
      function(reason)
       print('sntp sync failed, reason:'..reason)
      end
    )
end
