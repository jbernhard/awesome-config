local cpu = {}

cpu.usage = wibox.widget.textbox()

cpu.temp = {}

cpu.icon = wibox.widget.imagebox()
cpu.icon:set_image("/usr/share/icons/oxygen/22x22/devices/cpu.png")


local f = io.popen('nproc')
local nproc = tonumber(f:read()) 
f:close()

vicious.cache('cpu')

vicious.register(cpu.usage, vicious.widgets.cpu, 
  function (widget, args)
    local usage = {}

    for i = 2,1+nproc do
      table.insert(usage, '<span color ="'..gradient(0, 100, args[i])..'">'..string.format("%02.0f", args[i])..'</span>')
    end

    return table.concat(usage, ' ')
  end, 5)


vicious.cache('thermal')

for i = 2,1+awful.util.pread("awk '/cpu cores/ {print $4}' /proc/cpuinfo | uniq") do
  local w = wibox.widget.textbox() 

  vicious.register(w, vicious.widgets.thermal, 
    function (widget, args)
      return '<span color ="'..gradient(cputempmin, cputempmax, args[1])..'">'..args[1]..'</span>'
    end, 5, {'coretemp.0', 'core', 'temp'..i..'_input'})

    table.insert(cpu.temp, w)
end


return cpu
