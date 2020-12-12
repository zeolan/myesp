servo_power_pin = 11 --S3
servo_pin = 3
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
