sntp.sync("ua.pool.ntp.org",
  function(sec, usec, server, info)
    print('sync', sec, usec, server)
    tm = rtctime.epoch2cal(sec)
    print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
  end,
  function()
   print('failed!')
  end
)

