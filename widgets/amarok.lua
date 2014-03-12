local amarok = {}

amarok.text = wibox.widget.textbox()
amarok.icon = wibox.widget.imagebox()


function amarok.update()
  amarok.text:set_text(amarok.shorttitle)
  amarok.icon:set_image(amarok.cover)
end


function amarok.stop()
  amarok.title = '[stopped]'
  amarok.shorttitle = '--'
  amarok.meta = ''
  amarok.cover = "/usr/share/icons/oxygen/48x48/actions/media-playback-stop.png"

  amarok.update()
end


function amarok.set(title,cover,artist,genre,album,year)
  amarok.title = title:gsub("&","&amp;")

  if title:len() > 40 then
    amarok.shorttitle = amarok.title:sub(1, 40).."..."
  else
    amarok.shorttitle = amarok.title
  end

  if cover == '' then
    amarok.cover = "/usr/share/icons/oxygen/48x48/actions/media-playback-start.png"
  else
    amarok.cover = cover
  end

  amarok.meta = artist..' / '..genre..'\n'..album..' / '..year

  amarok.update()
end


function amarok.pause()
  amarok.text:set_text('['..amarok.shorttitle..']')
end


-- popup
amarok.text:connect_signal("mouse::enter", function()
  amarok_popup = naughty.notify({
    icon = amarok.cover, 
    title = amarok.title,
    text = amarok.meta, 
    timeout = 0, hover_timeout = 0.5
  })
end)
amarok.text:connect_signal("mouse::leave", function()
  if amarok_popup ~= nil then
    naughty.destroy(amarok_popup)
  end
end)

return amarok
