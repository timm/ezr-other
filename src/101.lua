local help = [[
mylo: recursive bi-clustering via random projections (lo is less. less is more. go lo)
(c) 2023, Tim Menzies, BSD-2

USAGE:
  lua mylo.lua [OPTIONS]

OPTIONS:
  -b --bins   max number of bins              = 16
  -B --Beam   max number of ranges            = 10
  -c --cohen  small effect size               = .35
  -C --Cut    ignore ranges less than C*max   = .1
  -d --d      frist cut                       = 32
  -D --D      second cut                      = 4
  -f --file   csv data file name              = ../data/diabetes.csv
  -F --Far    how far to search for faraway?  = .95
  -h --help   show help                       = false
  -H --Half   #items to use in clustering     = 256
  -p --p      weights for distance            = 2
  -s --seed   random number seed              = 31210
  -S --Support coeffecient on best            = 2
  -t --todo   start up action                 = help]]
-------------------------------------------------------------
-- ## Variables

local m={}   -- this module
local b4={}; for k, _ in pairs(_ENV) do b4[k]=k end -- used to find bad globals
local the={} -- contains option=value; built from above help string
local eg={}  -- for our start-up routines
local l={}   -- defines some standard library tools
------------------------------------------------------------
-- ## Lib

-- Return keys, sorted.
function l.keys(t,    u)
  u={}; for k,_ in pairs(t) do u[1+#u]=k end; table.sort(u); return u end

-- Prune leading and trailing blanks
function l.trim(s) return s1:match"^%s*(%S+)" end


-- Coerce a string to some thing.
function l.is(s) 
  return math.tointeger(s) or tonumber(s) or s=="true" or (s~="false" and s) end

-- Return rows of a csv file.
function l.csv(src)
  src = src=="-" and io.stdin or io.input(src)
  return function(      s,t)
    s=io.read()
    if   s 
    then t={}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=l.is(l.trim(s1)) end; return t 
    else io.close(src) end end end

-- Update table from CLI. Non-booleans need values but for booleans, we just flip the default.
function l.cli(t)
  for k, v in pairs(t) do
    v = tostring(v)
    for argv,s in pairs(arg) do
      if s=="-"..(k:sub(1,1)) or s=="--"..k then
        v = v=="true" and "false" or v=="false" and "true" or arg[argv + 1]
        t[k] = l.coerce(l.trim(v)) end end end
  if t.help then os.exit(print("\n"..help)) end 
  return t end

function l.reset(fun,     old)
   old={}; for k,v in pairs(the) do old[k]=v end
   math.randomseed(the.seed or 1234567890) -- set up
   status = fun()
   for k,v in pairs(old) do the[k]=v end -- tear down
   return status end

function l.run(k)
  return l.reset(function ()
    if eg[k] and eg[k]()==false then
      io.stderr:write(l.fmt("# !!!!!!!! FAIL [%s]\n",k)) 
      return True end end) end

-- Run all examples
function eg.all(     bads)
  bads=0
  for _,k in pairs(l.keys(eg)) do 
    if k ~= "all" then 
      if run(k) then bads=bads+1 end end end
  if bads>0 then io.stderr:write(l.fmt("# !!!!!!!! FAIL(s): %s\n",bads)) end
  os.exit(bads) end
------------------------------------------------------------
-- ## Start-up

-- Build `the` from `help`.
for k, s1 in help:gmatch("[-][-]([%S]+)[^=]+= ([%S]+)") do the[k] = l.is(s1) end

-- If we are in the driver's seat, then update `the` from command line and run something.
if not pcall(debug.getlocal, 4, 1) then 
   l.run(l.cli(the).todo) end
   for k,v in pairs(_ENV) do  
     if not b4[k] then print("E: bad global?",k,type(k)) end end

return m
