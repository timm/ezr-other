local stats = require "stats"
local NUM = {}

-- asdaasddas

function NUM:new(s, n)
  return {txt=s or " ", at=n or 0, n=0,
          mu=0, m2=0, sd=0, hi=-1E30, lo=1E30,
          heaven= (s or ""):find"-$" and 0 or 1} end

-- asdaas
function NUM:add(x,     d)
  if x ~="?" then
    self.n  = self.n+1
    d       = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n < 2 and 0 or  (self.m2/(self.n-1))^.5
    self.lo = math.min(x, self.lo)
    self.hi = math.max(x, self.hi) end end

function NUM:bin(x,bins,      lo,mid,hi,p)
  mid = self.mu
  hi  = mid + 3*self.sd
  lo  = mid - 3*self.sd
  p   = stats.cdf.triangular(x,lo,mid,hi)
  return lo + math.floor(p*bins)*(hi - lo) end

function NUM:like(x,_)
  return stats.cdf.gaussian(x,self.mu, self.sd) end

return NUM