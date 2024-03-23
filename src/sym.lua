-- Incrementally 
local l = require"lib"
local SYM = l.obj"SYM"

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
function SYM:mid() return l.mode(self.has) end

-- Returns a measure of disorder
function SYM:div() return l.entropy(self.has) end

-- Returns likelihood that  `x` comes from `self`.
function SYM:like(x,prior,m,_)
  return ((self.has[x] or 0) + m*prior)/(self.n + m) end

return SYM