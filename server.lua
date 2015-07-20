Rcolor = 1023
Gcolor = 1023
Bcolor = 1023

function set_color (color)
    Rcolor = tonumber(string.sub(color, 1, 2), 16)
    Gcolor = tonumber(string.sub(color, 3, 4), 16)
    Bcolor = tonumber(string.sub(color, 5, 6), 16)
    if Rcolor>0 then 
        Rcolor = (Rcolor+1)*4 -1
    end
    if Gcolor>0 then 
        Gcolor = (Gcolor+1)*4 -1
    end
    if Bcolor>0 then 
        Bcolor = (Bcolor+1)*4 -1
    end
    pwm.setduty(7, Rcolor) -- GPIO_13
    pwm.setduty(6, Gcolor) -- GPIO_12
    pwm.setduty(5, Bcolor) -- GPIO_14
    print('Red', Rcolor)
    print('Green', Gcolor)
    print('Blue', Bcolor)
end

srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then 
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP"); 
        end
        local _GET = {}
        if (vars ~= nil)then 
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do 
                _GET[k] = v
            end
            if (_GET.color ~= nil) then
                print(_GET.color)
                set_color(_GET.color)
            elseif (_GET.sys ~= nil) then
                if (_GET.sys == "On") then
                    pwm.setduty(7, Rcolor)
                    pwm.setduty(6, Gcolor)
                    pwm.setduty(5, Bcolor)
                elseif (_GET.sys == "Off") then
                    pwm.setduty(7, 0)
                    pwm.setduty(6, 0)
                    pwm.setduty(5, 0)
                end
            end
        end
        print("Start!")
        file.open("index.html", "r")
        while true do
            temp = file.readline()
            if (temp == nil) then
                break
            else
                buf = buf..string.sub(temp, 1, -2)
            end
        end
        file.close()
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
