pin = 2

mytimer = tmr.create()
mytimer:register(10,
                 tmr.ALARM_SINGLE,
                 function()
                    print("timer stopped")
                    pwm.stop(pin)
                 end
                 )
                     
function start(duty)
    pwm.setup(pin, 50, duty)
    pwm.start(pin)
    mytimer:start()
end
