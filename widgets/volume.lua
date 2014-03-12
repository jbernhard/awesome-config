local volume = {}

volume.text = wibox.widget.textbox()
volume.icon = wibox.widget.imagebox()

function volume.seticon(arg)
  if arg == -1  then
    volume.icon:set_image("/usr/share/icons/oxygen/22x22/status/audio-volume-muted.png")
  else
    if arg > 66 then
      volume.icon:set_image("/usr/share/icons/oxygen/22x22/status/audio-volume-high.png")
    elseif arg > 33 then
      volume.icon:set_image("/usr/share/icons/oxygen/22x22/status/audio-volume-medium.png")
    else 
      volume.icon:set_image("/usr/share/icons/oxygen/22x22/status/audio-volume-low.png")
    end
  end
end

function volume.set(arg)
  local basecmd

  if river then
    basecmd = 'amixer -c Intel'
  else
    basecmd = 'amixer'
  end

  local cmd

  if arg == nil or arg == 'mute' then
    cmd = basecmd..' get Master'
  else
    cmd = basecmd..' set Master '..arg
  end

  local amixer = awful.util.pread(cmd)

  local vol, mute = string.match(amixer, "([%d]+)%%.*%[([%l]*)")

  if arg == 'mute' then
    if mute == 'off' then
      awful.util.pread(basecmd.." set Master unmute")
      volume.seticon(tonumber(vol))
    else
      awful.util.pread(basecmd.." set Master mute")
      volume.seticon(-1)
    end
  else
    if mute == 'off' then
      volume.seticon(-1)
    else
      volume.seticon(tonumber(vol))
    end
  end

  volume.text:set_text(vol)
end

return volume
