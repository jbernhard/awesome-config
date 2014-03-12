function dec2hex(s)
  return string.format("%02x", s)
end

local maxc = 250
local minc = 10
local mincg = 100

function gradient(min, max, val)
  if (val > max) then 
    val = max
  elseif (val < min) then 
    val = min
  -- workaround nan/inf problem
  elseif not (min <= val and val <= max) then
    val = min
  end

  local r, g, b
  local v = val - min
  local range = max - min
  local slope = 4*(maxc - minc)/range
  local slopeg = 4*(maxc - mincg)/range

  if (v <= range/4) then
    r = minc
    g = mincg + slopeg*v
    b = maxc
  elseif (v <= range/2) then
    r = minc
    g = maxc
    b = maxc - slope*(v - range/4)
  elseif (v <= 3*range/4) then
    r = minc + slope*(v - range/2)
    g = maxc
    b = minc
  else
    r = maxc
    g = maxc - slope*(v - 3*range/4)
    b = minc
  end

  return "#"..dec2hex(r)..dec2hex(g)..dec2hex(b)
end

return gradient
