require "http"
disp = lm3s.disp

--configure
ledpin = pio.PF_0

tempg = {}
tempg.max = 0
tempg.min = 0
tempg.t = 0
tempg.rh = 0
tempg.datum = ""
tempg.update = false

first_time = true
--init
disp.init( 1000000 )
disp.on()
pio.pin.setdir( pio.OUTPUT, ledpin )

function log( msg )
  print(msg)
end

function lcdon( )
  log("lcdon")
  disp.on()
  --timerOneShot(5, lcdoff, tmr.VIRT2)
end

function lcdoff( )
  log("lcdoff")
  disp.off()
end

function vreme()
  log("vreme")
  pio.pin.sethigh( ledpin )

  str = http.request{url = "http://query.yahooapis.com/v1/public/yql?q=select%20metData.t%2CmetData.tsValid_issued%2CmetData.rh%20%20from%20xml%20where%20url%3D%22http%3A%2F%2Fmeteo.arso.gov.si%2Fuploads%2Fprobase%2Fwww%2Fobserv%2Fsurface%2Ftext%2Fsl%2FobservationAms_BABNO-POL_latest.xml%22&format=json&callback="}
  --print(str.raw)

  if not (str.raw == nil) then 
    ts = string.gsub(str.raw, '"t":"(.+)",', function(f)
        tempg.t  = tonumber(f)

        if tempg.t  > tempg.max then
          tempg.max = tempg.t 
        end

        if tempg.t  < tempg.min then
          tempg.min = tempg.t 
        end

        print(f)
        return ""
    end)
    ts = string.gsub(str.raw, '"tsValid_issued":"(.+) CET"', function(f)
        tempg.datum = f
        print(f)
        return ""
    end)
    ts = string.gsub(str.raw, '"rh":"(.+)"', function(f)
        tempg.rh = f
        print(f)
        return ""
    end)
    tempg.update = true
  else
    log("no data")
  end
  log("after")
  collectgarbage('collect')
  pio.pin.setlow( ledpin )
  return vob
end

-- helper for pasring and displaying
function refresh()
  
  if tempg.update then
    log("refresh")
    disp.print( "Vreme @ Babno Polje", 2, 1*8, 0xff )

    disp.print( tempg.datum, 2, 3*8, 0xff )

    disp.print( "Temperatura: ".. tempg.t .."C", 2, 5*8, 0xff )
    disp.print( "Min: ".. tempg.min .."C", 2, 6*8, 0xff )
    disp.print( "Max: ".. tempg.max .."C", 2, 7*8, 0xff )
    disp.print( "RH: ".. tempg.rh .."%", 2, 8*8, 0xff )
    disp.print( "@dz0ny", 2, 10*8, 0xff )
    tempg.update = false
  end

end

log("handlers")

function timerRepeat( delay, fun, timer )
  -- Set timer interrupt handler
  cpu.set_int_handler( cpu.INT_TMR_MATCH, fun )
  -- Setup periodic timer interrupt for virtual timer N
  tmr.set_match_int(timer, delay*1000*1000, tmr.INT_CYCLIC)
  -- Enable timer match interrupt on virtual timer N
  cpu.sei( cpu.INT_TMR_MATCH, timer )
end

function timerOneShot( delay, fun, timer )
  -- Set timer interrupt handler
  cpu.set_int_handler( cpu.INT_TMR_MATCH, fun )
  -- Setup periodic timer interrupt for virtual timer N
  tmr.set_match_int(timer, delay*1000*1000, tmr.INT_ONESHOT)
  -- Enable timer match interrupt on virtual timer N
  cpu.sei( cpu.INT_TMR_MATCH, timer )
end

-- Update vreme
timerRepeat(30, vreme, tmr.VIRT3)


--main
while true do
  
  if first_time then
    vreme()
    first_time = false
  end

  refresh()
end