function sntp_sync_callback(sec, usec, server, info)
    local tm = rtctime.epoch2cal(sec)
    --print("===================================")
    --print(string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
    if g_vent_mode == MODE_AUTO and not g_cycle_started and tm["min"]%g_cycle == 0 then
        g_cycle_started = true
        --print("=== start cycle")
        --print(string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
        send_status("AUTO->ON")
        m:publish("vent/speed", g_vent_speed, 0, 0, nil)
        m:publish("vent/servo", 1, 0, 0, nil)
    end
    if g_cycle_started and tm["min"]%g_cycle >= g_cycle_on then
        g_cycle_started = false
        --print("=== end cycle")
        --print(string.format("%04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"]))
        if g_vent_mode == MODE_AUTO then
            set_speed(0)
            set_heater(0)
            send_status("AUTO->OFF")
            m:publish("vent/servo", 0, 0, 0, nil)
        end
    end
    --collectgarbage("collect")
end

function sntp_sync()
    g_cnt = g_cnt + 1
    print("sntp_sync "..g_cnt)
    if g_vent_mode == MODE_ON then
        if g_cnt*10 >= g_cycle_on*60 then
            g_cnt = 0
            m:publish("vent/mode", MODE_OFF, 0, 0, nil)
            m:publish("vent/servo", 0, 0, 0, nil)
        end
    end
    g_heat_cycle = g_heat_cycle + 1 
    
    t:read_temp(readout, ow_pin, t.C)  
     
    if (g_cnt % 2) == 0 then
        sntp.sync("ua.pool.ntp.org",
            sntp_sync_callback,
            function(reason)
            --print('sntp sync failed, reason:'..reason)
            end
        )
    end
    --collectgarbage("collect")
end
