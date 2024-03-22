-- Incrementally 
l=require"lib"
local SYM=l.obj"SYM"

function SYM:new(s,n)
  return {txt=s or " ", at=n or 0, n=0, has={}} end

-- Increment.
function SYM:add(x,  n)
  n=n or 1
  if x ~= "?" then 
    self.n = self.n + n
    self.has[x] = (self.has[x] or 0) + n end end

-- Decrement.
function SYM:sub(x,  n) return self:add(x,-1) end

-- Returns the usual value
function SYM:mid() return lib.mode(self.has) end

-- Returns a measure of disorder
function SYM:div() return l.entropy(self.has) end

-- Returns likelihood that  `x` comes from `self`.
function SYM:like(x,prior,m,_)
  return ((self.has[x] or 0) + m*prior)/(self.n + m) end

-- Return a merge if (10 parts are too rare or (2) merge is not more disorderd. 
function SYM.merged(i,j,enough,    k) 
  k = SYM(i.txt,i.at)
  for _,sym in pairs{i,j} do
    for x,n in pairs(sym) do k:add(x,n) end end
  if i.n < (enough or 0) or j.n < (enough or 0) then return k end -- (1)
  if k:div() <= (i.n*i:div() + j.n*j:div())/k.n then return k end end -- (2)

return SYM
