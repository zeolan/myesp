def do_connect():
    import network
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if not wlan.isconnected():
        print('connecting to network...')
        wlan.connect('MikroTik-D9809F', '$Gadget2011')
        while not wlan.isconnected():
            pass
    print('network config:', wlan.ifconfig())

do_connect()
