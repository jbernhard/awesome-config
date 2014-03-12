local clock = {}

clock.text = awful.widget.textclock("%a %d %b, %H:%M", 15) 

clock.text:connect_signal("mouse::enter", function()
  calendar = naughty.notify({
    icon = "/usr/share/icons/oxygen/128x128/mimetypes/text-calendar.png", 
    text = awful.util.pread("cal -3m"),
    font = 'Deja Vu Sans Mono '..fontsize,
    timeout = 0, hover_timeout = 0.5
  })
end)
clock.text:connect_signal("mouse::leave", function()
  if calendar ~= nil then
    naughty.destroy(calendar)
  end
end)

clock.icon = wibox.widget.imagebox()
clock.icon:set_image("/usr/share/icons/oxygen/22x22/apps/clock.png")

return clock
