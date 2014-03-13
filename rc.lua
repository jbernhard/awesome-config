-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
menubar = require("menubar")
-- Vicous widgets
vicious = require("vicious")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
                   title = "Oops, there were errors during startup!",
                   text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, an error happened!",
                     text = err })
    in_error = false
  end)
end
-- }}}


-- {{{ Variable definitions
-- directory shortcuts
home = os.getenv('HOME')
conf = awful.util.getdir("config")

-- hostname
local f = io.popen('hostname')
local hostname = f:read()
f.close()

if hostname == 'river' then
  river = true
  resolution = 2048
  fontsize = 9
  cputempmin = 28
  cputempmax = 60
elseif hostname == 'ice9' then
  ice9 = true
  resolution = 1920
  fontsize = 10
  cputempmin = 43
  cputempmax = 83
elseif hostname == 'serenity' then
  serenity = true
  resolution = nil
  fontsize = 12
  cputempmin = 25
  cputempmax = 50
end

-- Themes define colours, icons, and wallpapers
beautiful.init(conf.."/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
  awful.layout.suit.tile.left, --1
  awful.layout.suit.max, --2
  awful.layout.suit.tile, --3
  awful.layout.suit.tile.bottom, --4
  awful.layout.suit.tile.top, --5
  awful.layout.suit.floating, --6
  awful.layout.suit.fair, --7
  awful.layout.suit.fair.horizontal, --8
  awful.layout.suit.spiral, --9
  awful.layout.suit.spiral.dwindle, --10
  awful.layout.suit.max.fullscreen, --11
  awful.layout.suit.magnifier --12
}
-- }}}

-- {{{ Random wallpaper
if resolution then
  function imglist(path)
      local files = {}

      local ls = io.popen('ls "'..path..'"') 

      for f in ls:lines() do
        if string.match(f,"%.png$") or string.match(f,"%.jpg$") then
          table.insert(files,f)
        end
      end

      ls.close()

      return files
  end

  function randomwallpaper(path,files)
    for s = 1, screen.count() do
      gears.wallpaper.maximized(path..files[math.random(1, #files)], s, true)
    end
  end

  math.randomseed(os.time())

  wp_path = home..'/img/wallpapers/'..resolution..'/'
  wp_files = imglist(wp_path)

  wp_timeout = 900
  wp_timer = timer { timeout = wp_timeout }
  wp_timer:connect_signal("timeout", function() randomwallpaper(wp_path,wp_files) end)
 
  randomwallpaper(wp_path,wp_files)
  wp_timer:start()
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  names = { "1", "2", "3", "'", ",", ".", "a", "o", "e" },
  layouts = { layouts[1], layouts[1], layouts[1],
              layouts[1], layouts[2], layouts[1],
              layouts[1], layouts[1], layouts[1] }
}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
 tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- {{{ Menu
-- actually just a placeholder icon
mylauncher = wibox.widget.imagebox()
mylauncher:set_image(beautiful.awesome_icon)
-- }}}

-- {{{ Wibox
-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                            if c == client.focus then
                                              c.minimized = true
                                            else
                                              -- Without this, the following
                                              -- :isvisible() makes no sense
                                              c.minimized = false
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              -- This will also un-minimize
                                              -- the client, if needed
                                              client.focus = c
                                              c:raise()
                                            end
                                          end),
                     awful.button({ }, 3, function ()
                                            if instance then
                                              instance:hide()
                                              instance = nil
                                            else
                                              instance = awful.menu.clients({ width=250 })
                                            end
                                          end),
                     awful.button({ }, 4, function ()
                                            awful.client.focus.byidx(1)
                                            if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                            awful.client.focus.byidx(-1)
                                            if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
                         awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                         awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                         awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                         awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mylauncher)
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()

  -- make spacers and separators; these are used lot
  local spacer1 = wibox.widget.textbox()
  local spacer2 = wibox.widget.textbox()
  local spacer3 = wibox.widget.textbox()
  local separator = wibox.widget.textbox()
  spacer1:set_text(' ')
  spacer2:set_text('  ')
  spacer3:set_text('   ')
  separator:set_text(' : ')

  -- include gradient
  gradient = require("util/gradient")

  -- extra spacer on the far LHS
  right_layout:add(spacer1)

  -- amarok
  if river or ice9 then
    amarok = require('widgets/amarok')
    right_layout:add(amarok.icon)
    right_layout:add(spacer1)
    right_layout:add(amarok.text)
    amarok.stop()

    right_layout:add(spacer3)
  end

  -- network
  network = require('widgets/network')
  right_layout:add(network.icon)
  right_layout:add(spacer1)
  if ice9 then right_layout:add(network.wifi) end
  right_layout:add(network.speed)
  if ice9 then network.update() end

  right_layout:add(spacer2)

  -- cpu
  cpu = require('widgets/cpu')
  right_layout:add(cpu.icon)
  right_layout:add(spacer1)
  right_layout:add(cpu.usage)
  right_layout:add(separator)
  for i,w in ipairs(cpu.temp) do
    right_layout:add(w)
    right_layout:add(spacer1)
  end

  right_layout:add(spacer2)

  -- battery
  if ice9 then
    battery = require('widgets/battery')
    right_layout:add(battery.icon)
    right_layout:add(spacer1)
    right_layout:add(battery.text)

    right_layout:add(spacer3)
  end

  -- volume
  if river or ice9 then
    volume = require('widgets/volume')
    right_layout:add(volume.icon)
    right_layout:add(spacer1)
    right_layout:add(volume.text)
    volume.set()

    right_layout:add(spacer3)
  end

  -- clock
  clock = require('widgets/clock')
  right_layout:add(clock.icon)
  right_layout:add(spacer1)
  right_layout:add(clock.text)

  right_layout:add(spacer1)

  -- system tray on the primary screen
  if s == 1 then
    right_layout:add(wibox.widget.systray())
    right_layout:add(spacer1)
  end

  right_layout:add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
  awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

  awful.key({ modkey,           }, "j",
    function ()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,           }, "k",
    function ()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
  awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
  awful.key({ modkey,           }, "`", function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
  awful.key({ modkey,           }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),

  -- Standard program
  awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey, "Control", "Shift" }, "q", awesome.quit),

  awful.key({ modkey,           }, "s",     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
  awful.key({ modkey, "Shift"   }, "s",     function () awful.tag.incnmaster(-1)      end),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
  awful.key({ modkey, "Control" }, "s",     function () awful.tag.incncol(-1)         end),
  awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

  awful.key({ modkey, "Control" }, "n", awful.client.restore),

  -- Prompt
  awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

  awful.key({ modkey }, "x",
            function ()
              awful.prompt.run({ prompt = "Run Lua code: " },
              mypromptbox[mouse.screen].widget,
              awful.util.eval, nil,
              awful.util.getdir("cache") .. "/history_eval")
            end),

  -- applications
  awful.key({ modkey,           }, "c", function () awful.util.spawn("chromium") end),
  awful.key({ modkey,           }, "p", function () awful.util.spawn("ipython qtconsole") end),
  
  -- print screen
  awful.key({ }, "Print", function () awful.util.spawn_with_shell("ksnapshot") end)
)

if river or ice9 then
  globalkeys = awful.util.table.join(
    globalkeys,
    -- amarok
    awful.key({ modkey, }, "d", function () awful.util.spawn("amarok") end),
    awful.key({ modkey, "Shift" }, "v", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.StopAfterCurrent") end),
    -- volume
    awful.key({ }, "XF86AudioRaiseVolume", function () volume.set('1%+') end),
    awful.key({ }, "XF86AudioLowerVolume", function () volume.set('1%-') end),
    awful.key({ "Shift" }, "XF86AudioRaiseVolume", function () volume.set('5%+') end),
    awful.key({ "Shift" }, "XF86AudioLowerVolume", function () volume.set('5%-') end),
    awful.key({ }, "XF86AudioMute", function () volume.set('mute') end)
  )
end

if river then
  globalkeys = awful.util.table.join(
    globalkeys,
    -- amarok playback control
    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.PlayPause") end),
    awful.key({ }, "XF86AudioStop", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.Stop") end),
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.Prev") end),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.Next") end)
  )
elseif ice9 then
  function getbrightness()
    local state = awful.util.pread('asus-brightness screen')
    local n = tonumber(state)-1
    local grey = string.format('%02x',n*255/100)
    
    local settings = {
        fg = n > 50 and '#000000' or '#ffffff',
        bg = '#'..grey..grey..grey,
        height = 24,
        width = 26,
        font = 'Deja Vu Sans Mono 10',
        title = string.format('%02d',state),
        timeout = 1
      }

    if brightnessid ~= nil then
        settings.replaces_id = brightnessid
    end

    brightnessid = naughty.notify(settings).id
  end

  globalkeys = awful.util.table.join(
    globalkeys,
    -- amarok playback control
    awful.key({ }, "XF86Launch6", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.PlayPause") end),
    awful.key({ modkey, "Shift" }, "Down", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.PlayPause") end),
    awful.key({ modkey, "Shift" }, "Up", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.Stop") end),
    awful.key({ modkey, "Shift" }, "Left", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.Prev") end),
    awful.key({ modkey, "Shift" }, "Right", function () awful.util.spawn_with_shell("qdbus-qt4 org.kde.amarok /Player org.freedesktop.MediaPlayer.Next") end),
    -- screen brightness
    awful.key({ }, "XF86MonBrightnessDown", function () getbrightness() end ),
    awful.key({ }, "XF86MonBrightnessUp", function () getbrightness() end ),
    awful.key({ modkey, }, "F7", function () awful.util.spawn_with_shell("sleep .2 && xset dpms force standby") end),
    -- keyboard backlight
    awful.key({ }, "XF86KbdBrightnessDown", function () awful.util.spawn_with_shell("asus-brightness kb -") end),
    awful.key({ }, "XF86KbdBrightnessUp", function () awful.util.spawn_with_shell("asus-brightness kb +") end),
    -- touchpad
    awful.key({ }, "XF86TouchpadToggle", function () awful.util.spawn_with_shell("touchpad toggle") end)
  )
elseif serenity then
  globalkeys = awful.util.table.join(
    globalkeys,
    -- xbmc
    awful.key({ }, "XF86HomePage", function () awful.util.spawn("xbmc") end),
    -- black screen
    awful.key({ modkey }, "d", function () awful.util.spawn_with_shell("convert -size 1920x1080 xc:black png:- | feh -FY -") end),
    -- auto fullscreen mlb.tv
    awful.key({ modkey, "Shift" }, "Escape", 
    function () 
      awful.tag.history.restore() 
      mouse.coords({ x=905, y=703 }) 
      awful.util.spawn_with_shell('sleep .05 && xdotool click 1') 
    end)
  )
end

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, ";",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "`",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
      function (c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
      end),
    awful.key({ modkey,           }, "m",
      function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
      end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, tags.names[i],
                  function ()
                    local screen = mouse.screen
                    local tag = awful.tag.gettags(screen)[i]
                    if tag then
                      awful.tag.viewonly(tag)
                    end
                  end),
        awful.key({ modkey, "Control" }, tags.names[i],
                  function ()
                    local screen = mouse.screen
                    local tag = awful.tag.gettags(screen)[i]
                    if tag then
                      awful.tag.viewtoggle(tag)
                    end
                  end),
        awful.key({ modkey, "Shift" }, tags.names[i],
                  function ()
                    local tag = awful.tag.gettags(client.focus.screen)[i]
                    if client.focus and tag then
                      awful.client.movetotag(tag)
                    end
                  end),
        awful.key({ modkey, "Control", "Shift" }, tags.names[i],
                  function ()
                    local tag = awful.tag.gettags(client.focus.screen)[i]
                    if client.focus and tag then
                      awful.client.toggletag(tag)
                    end
                  end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = { border_width = beautiful.border_width,
                   border_color = beautiful.border_normal,
                   focus = awful.client.focus.filter,
                   keys = clientkeys,
                   buttons = clientbuttons } },
    -- some windows need to float
    { rule_any = { 
        class = { "MPlayer", "mplayer2", "Gimp", "Plugin-container", "feh", "Google-musicmanager", "Tk", "mpv" }, 
        instance = { "exe" },
        role = { "GtkFileChooserDialog" } },
      properties = { floating = true } },
    { rule = { class = "Chromium", role = "pop-up" },
      properties = { floating = true } },
    -- apps that run on specific tags
    { rule = { class = "Chromium", role = "browser" },
      properties = { tag = tags[1][1], switchtotag = false } },
    { rule = { class = "URxvt" },
      properties = { tag = tags[1][2], switchtotag = false, size_hints_honor = false } },
    { rule = { class = "Gvim" },
      properties = { tag = tags[1][5], switchtotag = false, size_hints_honor = false } },
    { rule = { class = "Amarok" },
      properties = { tag = tags[1][7], switchtotag = false } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)

  if not startup then
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  local titlebars_enabled = false
  if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
    awful.button({ }, 1, function()
      client.focus = c
      c:raise()
      awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
      client.focus = c
      c:raise()
      awful.mouse.client.resize(c)
    end)
    )

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(awful.titlebar.widget.iconwidget(c))
    left_layout:buttons(buttons)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(awful.titlebar.widget.floatingbutton(c))
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(awful.titlebar.widget.stickybutton(c))
    right_layout:add(awful.titlebar.widget.ontopbutton(c))
    right_layout:add(awful.titlebar.widget.closebutton(c))

    -- The title goes in the middle
    local middle_layout = wibox.layout.flex.horizontal()
    local title = awful.titlebar.widget.titlewidget(c)
    title:set_align("center")
    middle_layout:add(title)
    middle_layout:buttons(buttons)

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)
    layout:set_middle(middle_layout)

    awful.titlebar(c):set_widget(layout)
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
