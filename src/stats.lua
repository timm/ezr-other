local stats = {} 

-- Return the effort required to recreate the signal in `t`.
function stats.entropy(t,       e,n)
  n=0; for _,v in pairs(t) do n = n+v end
  e=0; for _,v in pairs(t) do if v > 0 then e = e-v/n * math.log(v/n,2) end end
  return e,n end

-- Return the most frequent symbol within `t`.
function stats.mode(t,        x,n)
  n=0; for k,n1 in pairs(t) do if n1>n then x,n = k,n1 end end; return x end

-- ## Cumulative distribution functions
-- -  How likely is    `x` in a curve reporting
--    that some function is  less than or equal to `x`? 

stats.cdf = {}

-- CDF for triangular
function stats.cdf.triangluar(x,lo,mid,hi)
  if x <= lo then return 0 end
  if x >= hi then return 1 end
  if x <= mid then return (x-lo)^2/((hi-lo)*(mid-lo)) end
  return 1-(hi-x)^2/((hi-lo)*(hi-mid)) end

-- CDF for gaussians
function stats.cdf.gaussian(x,mu,sd)
  sd = sd + 1E-30
  return 2.71828^(-.5*(x - mu)^2/(sd^2)) / (sd*2.50663) end

return stats