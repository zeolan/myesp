MODE_OFF       = 0
MODE_ON        = 1
MODE_AUTO      = 2
MODE_POST_VENT = 3
MODE_PRE_HEAT  = 4

g_cycle_started = false
g_on_off = 0
g_cycle = nil
g_cycle_on = nil
g_vent_mode = MODE_OFF
g_vent_speed = nil
g_topic = nil
g_data = nil
g_tmr_interval = nil
g_t_max = 300
g_t_min = 250
g_heat_cycle = 0
g_heat_status = 0
g_cnt = 0
g_servo_mode = 0
g_mqtt_connected = false

g_myTimer = nil

m = nil
t = require("ds18b20")

gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.LOW)

function timerSetup(interval)
    if g_myTimer ~= nil then
        g_myTimer:stop()
        g_myTimer:interval(interval*1000)
        g_myTimer:start()
        g_tmr_interval = interval
        print("--timer changed")
    else
        g_myTimer = tmr.create()
        g_myTimer:register(interval*1000, tmr.ALARM_AUTO, sntp_sync);
        g_myTimer:start()
        print("--timer started with interval "..interval)
    end
end

local servo_power_pin = 11 --S3
local servo_pin = 3
servo_open = 120
servo_close = 78

gpio.mode(servo_power_pin, gpio.OUTPUT)
gpio.write(servo_power_pin, gpio.LOW)
servo_timer = tmr.create()

function servo_timer_start(duty)
    servo_timer:register(500,
                 tmr.ALARM_SINGLE,
                 function()
                    gpio.write(servo_power_pin, gpio.LOW)
                    pwm.stop(servo_pin)
                 end
                 )
    gpio.write(servo_power_pin, gpio.HIGH)
    pwm.setup(servo_pin, 50, duty)
    pwm.start(servo_pin)
    servo_timer:start()
end

dofile("read_settings.lua")
dofile("ds18b20_example.lua")
dofile("sntp.lua")
dofile("wifi_register.lua")
dofile("relay_init.lua")
dofile("mqtt_process.lua")
dofile("http_server.lua")

station_cfg={}
station_cfg.ssid="MikroTik-D9809F"
station_cfg.pwd="$Gadget2011"
station_cfg.save=true
wifi.setmode(wifi.STATION)
--local cfg = dofile("eus_params.lua")
wifi.sta.config(station_cfg)
--wifi.sta.connect()
--print(wifi.sta.getconfig())

--wifi.setmode(1)
--wifi.sta.connect()

-----------------------------------
function send_status(status)
    m:publish("vent/status", status, 1, 0, nil)
end

startMQTT = (function ()
    m = mqtt.Client("123", 120, "user1", "User1")

    m:connect("m23.cloudmqtt.com", 16312, false, function(client)
            --print("mqtt client connected")
            g_mqtt_connected = true

            -- subscribe topic with qos = 0
            client:subscribe("vent/+", 0,
                function(client)
                    gpio.write(4, gpio.HIGH)
                    client:publish("vent/cycle_on", g_cycle_on, 0, 0, nil)
                    client:publish("vent/speed", g_vent_speed, 0, 0, nil)
                    client:publish("vent/on_off", g_on_off, 0, 0, nil)
                    client:publish("vent/mode", g_vent_mode, 0, 0, nil)
                    client:publish("vent/heat", 0, 0, 0, nil)
                    send_status("READY")
                end
            )
        end,
        function(client, reason)
          print("failed reason: " .. reason)
        end
    )

    m:on("message", function(client, topic, data)
        g_topic = topic
        g_data = data
        process_mqtt(topic, data)
    end)

    m:on("offline", function(client, reason) g_mqtt_connected = false print('===offline') end)
end)

function saveSettings(name,value)
  file_name = name..".dat"
  file.remove(file_name)
  file.open(file_name,"w+")
  file.write(tostring(value))
  file.close()
end
