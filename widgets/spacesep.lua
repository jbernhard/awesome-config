-- spacers and separator widgets module

local spacesep = {}

function spacesep.spacer ()
  local widget = wibox.widget.textbox()
  widget:set_text(' ')
  return widget
end

function spacesep.bigspacer ()
  local widget = wibox.widget.textbox()
  widget:set_text('   ')
  return widget
end

function spacesep.separator ()
  local widget = wibox.widget.textbox()
  widget:set_text(' : ')
  return widget
end

return spacesep
