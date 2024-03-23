local l=require "lib"
local DATA=l.obj "DATA"

function DATA:new(src,  fun,order)
  self.rows={}
  if type(src) == "string"
  then for   t in l.csv(src)     do self:add(t, fun) end
  else for _,t in pairs(src or {}) do self:add(t, fun) end end
  if order then self:sort() end
  return self end

-- Update. If `fun` is defined, call it before updating anything.
function DATA:add(t,  fun)
  if   self.cols
  then if fun then fun(self,t) end
       self.rows[1 + #self.rows] = self.cols:add(t)
  else self.cols = COLS(t) end end

-- Sort-in-place the rows by distance to heaven.
function DATA:sort()
  return l.keysort(self.rows, function(t) return self:d2h(t) end) end

-- Return distance of goals to a hypothetical best heaven point.
function DATA:d2h(t,     d,n)
  d,n = 0,0
  for _,col in pairs(self.cols.y) do
    n = n + 1
    d = d + math.abs(col:norm(t[col.at]) - col.heaven)^2 end
  return (d/n)^0.5 end
