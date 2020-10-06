wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT,
    function()
        print("\n\tSTA - DHCP TIMEOUT")
    end
)
 
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,
    function(T)
        print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
        T.BSSID.."\n\treason: "..T.reason)
    end
)
 
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,
    function(T)
        print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
        T.BSSID.."\n\tChannel: "..T.channel)
    end
)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,
    function (T)
        print("\n\rGOT IP "..T.IP)
        if g_myTimer == nil then
            timerSetup(g_tmr_interval)
        end
        if m == nil then
            startMQTT()
        end
    end
)
