print ("wifi setup")
enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
    --wifi.setmode(wifi.STATION)
    --enduser_setup.stop()
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end
);
