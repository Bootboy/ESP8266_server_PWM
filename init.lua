gpio.mode(1, gpio.INPUT, gpio.PULLUP ) -- GPIO_5
w = 0

--pwm.setup(pin, clock, duty)
--pin: 1~12, IO индекс из таблицы
--clock: 1~1000, частота ШИМ
--duty: 0~1023, ШИМ коэффициент заполнения, максимально 1023(10бит)

pwm.setup(7, 500, 0) -- GPIO_13
pwm.setup(6, 500, 0) -- GPIO_12
pwm.setup(5, 500, 0) -- GPIO_14
pwm.start(7)
pwm.start(6)
pwm.start(5)

function start_SOFTAP ()
	wifi.setmode(wifi.SOFTAP);
	wifi.ap.config({ssid="ESP8266_RBG",pwd="12345678"});
end

function start_server ()
	tmr.stop(3)
	print("Start Server")
	dofile("server.lua")
end

function wait ()
    ip = wifi.sta.getip()
    if ip == nil then
    	print(w..". IP unavaiable, Waiting...")
    	w = w+1
    else
    	print("Config done, IP is "..ip)
    	start_server()
    end
    if w>49 then
    	print("Cannot connect to WIFI")
    	start_SOFTAP()
    	start_server()
    end
end

if gpio.read(1) == 0 then -- Если GPIO5 замкнут на землю, ESP создаст свою точку доступа
	print("GPIO5 = 1")
	start_SOFTAP()
	start_server()
elseif gpio.read(1) == 1 then -- Если GPIO5 не трогали, ESP приконектится к другому WI-FI
	file.open("wifi.txt", "r")
	ssid = file.readline()
	pas = file.readline()
	file.close()
	print("GPIO5 = 0")
	ip = wifi.sta.getip()
	print(ip)
	wifi.setmode(wifi.STATION)
	wifi.sta.config(ssid,pas)
	tmr.alarm(3,1000,1,wait)
end




