K1 = 8 --GPIO14
K2 = 7
K3 = 6
K4 = 5
gpio.mode(K1, gpio.OUTPUT)
gpio.mode(K2, gpio.OUTPUT)
gpio.mode(K3, gpio.OUTPUT)
gpio.mode(K4, gpio.OUTPUT)
gpio.write(K1, gpio.LOW)
gpio.write(K2, gpio.LOW)
gpio.write(K3, gpio.LOW)
gpio.write(K4, gpio.LOW)