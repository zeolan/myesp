pin = 1
gpio.mode(pin, gpio.INPUT, gpio.PULLUP)
pin_value = gpio.read(pin)
if pin_value == 1 then
    --gpio.mode(pin, gpio.OUTPUT)
    --dofile("wifi_register.lua")
    --dofile("sntp.lua")
    dofile("main.lua")
    --dofile("ds18b20_example.lua")
else
    dofile("wifi_setup.lua")
end
