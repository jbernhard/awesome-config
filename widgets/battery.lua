local battery = {}

battery.text = wibox.widget.textbox()
battery.icon = wibox.widget.imagebox()

vicious.register(battery.text, vicious.widgets.bat, 
  function (widget, args) 
    if args[1] == '−' then
      if args[2] > 90 then
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-100.png"
      elseif args[2] > 70 then
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-080.png"
      elseif args[2] > 45 then
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-060.png"
      elseif args[2] > 20 then
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-040.png"
      elseif args[2] > 7 then
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-caution.png"
      else
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-low.png"
        naughty.notify({
            icon = battery.image, 
            title = 'Low Battery',
            text = args[2]..'%',
            timeout = 2
        })
      end
    else
      if args[2] > 90 then
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-charging.png"
      elseif args[2] > 70 then                                                          
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-charging-080.png"
      elseif args[2] > 45 then                                                          
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-charging-060.png"
      elseif args[2] > 20 then                                                          
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-charging-040.png"
      elseif args[2] > 7 then                                                          
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-charging-caution.png"
      else                                                                              
        battery.image = "/usr/share/icons/oxygen/22x22/status/battery-charging-low.png"
      end
    end

    battery.icon:set_image(battery.image)

    local p = '<span color ="'..gradient(0, 100, 100-args[2])..'">'..args[2]..'</span>'
    if args[3] == 'N/A' then
      return p
    else
      return p..' ['..args[3]..']'
    end
  end, 37, 'BAT0')


return battery
