PWM_PIN = 2
-- start(120) - open
-- start(78) - close

mytimer = tmr.create()
mytimer:register(10,
                 tmr.ALARM_SINGLE,
                 function()
                    print("timer stopped")
                    pwm.stop(PWM_PIN)
                 end
                 )
                     
function start(duty)
    pwm.setup(PWM_PIN, 50, duty)
    pwm.start(PWM_PIN)
    mytimer:start()
end
