local network = {}

network.speed = wibox.widget.textbox()
network.icon = wibox.widget.imagebox()

if river or serenity then

  network.icon:set_image("/usr/share/icons/oxygen/22x22/devices/network-wired.png")
  vicious.register(network.speed, vicious.widgets.net, '${eth0 down_kb}↓ ${eth0 up_kb}↑', 5)

elseif ice9 then

  network.wifi = wibox.widget.textbox()
  network.iface = ''


  vicious.register(network.wifi, vicious.widgets.wifi, 
    function (widget, args)
      local p = args["{linp}"]
      local n

      if p > 75 then
        n = '100'
      elseif p > 50 then
        n = '75'
      elseif p > 25 then
        n = '50'
      elseif p > 0 then
        n = '25'
      else
        n = '00'
      end

      network.icon:set_image("/usr/share/icons/oxygen/22x22/devices/network-wireless-connected-"..n..".png")

      return '<span color ="'..gradient(0, 100, 100-p)..'">'..p..'</span> : '
    end, 23, 'wlan0')

  function network.update()
    local iface
    local ethup = false
    local operstate = io.open('/sys/class/net/eth0/operstate', 'r')

    if operstate then
      if operstate:read() == 'up' then
        ethup = true
      end
      io.close(operstate)
    end

    if ethup then 
      iface = 'eth0'
      if iface ~= network.iface then
        vicious.unregister(network.wifi, true)
        network.wifi:set_text('')
        network.icon:set_image("/usr/share/icons/oxygen/22x22/devices/network-wired.png")
        vicious.unregister(network.speed, false)
        vicious.register(network.speed, vicious.widgets.net, '${'..iface..' down_kb}↓ ${'..iface..' up_kb}↑', 5)
      end
    else
      iface = 'wlan0'
      if iface ~= network.iface then
        vicious.unregister(network.speed, false)
        vicious.register(network.speed, vicious.widgets.net, '${'..iface..' down_kb}↓ ${'..iface..' up_kb}↑', 5)
        vicious.activate(network.wifi)
      end
    end

    network.iface = iface
  end

end


return network
