require "http"
disp = lm3s.disp


--configure
ledpin = pio.PF_0

--init
disp.init( 1000000 )
disp.on()
pio.pin.setdir( pio.OUTPUT, ledpin )

--helper for get
function get( req )
  res = http.request{url = req}
  --print("code:".. res.code)
  --print("headers:".. res.headers)
  --print("body:".. res.body)
  if string.find(res.raw,"red") then
    return "red"
  elseif string.find(res.raw,"orange") then
    return "orange"
  elseif string.find(res.raw,"yellow") then
    return "yellow"
  elseif string.find(res.raw,"magenta") then
    return "magenta"
  elseif string.find(res.raw,"purple") then
    return "purple"
  elseif string.find(res.raw,"warmwhite") then
    return "warmwhite"
  elseif string.find(res.raw,"white") then
    return "white"
  elseif string.find(res.raw,"cyan") then
    return "cyan"
  elseif string.find(res.raw,"blue") then
    return "blue"
  elseif string.find(res.raw,"green") then
    return "green"
  else
    return "off"
  end
end

-- helper for pasring and displaying
function refresh()
  pio.pin.sethigh( ledpin )
  color = get("http://api.thingspeak.com/channels/1417/field/1/last.txt")
  disp.clear()
  disp.print( "@CheerLights", 2, 1*8, 0xff )
  disp.print( "controller with eLUA",2, 2*8, 0xff )
  disp.print( "Now: ".. color.." color", 2, 4*8, 0xff )
  disp.print( "by @dz0ny", 2, 6*8, 0xff )
  pio.pin.setlow( ledpin )
end

--main
while true do
  refresh()
  tmr.delay(16*1000*1000)
end