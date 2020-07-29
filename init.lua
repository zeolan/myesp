pin = 1
gpio.mode(pin, gpio.INPUT, gpio.PULLUP)
pin_value = gpio.read(pin)
if pin_value == 1 then
    dofile("main.lua")
    --dofile("websocket-client.lua")
else
    dofile("wifi_setup.lua")
end
