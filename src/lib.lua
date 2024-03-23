local lib={}
-------------------------------------------------------------------------------
-- ## Objects
function lib.obj(s,    t)
  t = {_name=s}
  t.__index = t
  t.__tostring=function(...) return lib.o(...) end                    
  return setmetatable(t, { __call=function(_,...)
    local i = setmetatable({},t)
    return setmetatable(t.new(i,...) or i,t) end}) end
-------------------------------------------------------------------------------
-- ## Numbers

-- Return number `n`, rounded to `ndec`imals.
function lib.rnd(n, ndecs)
  if type(n) ~= "number" then return n end
  if math.floor(n) == n  then return n end
  local mult = 10^(ndecs or 2)
  return math.floor(n * mult + 0.5) / mult end
-------------------------------------------------------------------------------
-- ## Strings

-- Prune leading and trailing blanks
function lib.trim(s) return s:match"^%s*(%S+)" end

-- Emulate sprintf
lib.fmt = string.format

-- Print a string of a nested structure.
function lib.oo(x) print(lib.o(x)); return x end

-- Rerun a string for a nested structure.
function lib.o(t,  n,      u)
  if type(t) == "number" then return tostring(lib.rnd(t, n)) end
  if type(t) ~= "table"  then return tostring(t) end
  u = {}
  for _,k in pairs(lib.keys(t)) do
    if tostring(k):sub(1,1) ~= "_" then
      u[1+#u]= #t>0 and lib.o(t[k],n) or lib.fmt("%s: %s", k, lib.o(t[k],n)) end end
  return (t._name or "").."{" .. table.concat(u, ", ") .. "}" end

-- Return a string for a nested structure.
function lib.o(t,  n,      u)
  if type(t) == "number" then return tostring(lib.rnd(t, n)) end
  if type(t) ~= "table"  then return tostring(t) end
  u={}
  for _,k in pairs(lib.keys(t)) do
    if tostring(k):sub(1,1) ~= "_" then
      u[1+#u]= #t>0 and lib.o(t[k],n) or lib.fmt("%s: %s",k,lib.o(t[k],n)) end end
  return "{" .. table.concat(u, ", ") .. "}" end
-------------------------------------------------------------------------------
-- ## Tables

-- Return keys, sorted.
function lib.keys(t,    u)
  u={}; for k,_ in pairs(t) do u[1+#u]=k end; table.sort(u); return u end

-- Return a new table, with old items sorted randomly.
function lib.shuffle(t,    u,j)
  u={}; for _,x in pairs(t) do u[1+#u]=x; end;
  for i = #u,2,-1 do j=math.random(i); u[i],u[j] = u[j],u[i] end
  return u end

-- Return `t` skipping `go` to `stop` in steps of `inc`.
function lib.slice(t, go, stop, inc,    u) 
  if go   and go   < 0 then go=#t+go     end
  if stop and stop < 0 then stop=#t+stop end
  u={}
  for j=(go or 1)//1,(stop or #t)//1,(inc or 1)//1 do u[1+#u]=t[j] end
  return u end

-- Schwartzian transform:  (1) decorate, (2) sort, (3) undecorate
function lib.keysort(t,fun,      u,v)
  u={}
  for _,x in pairs(t) do u[1+#u]={x=x, y=fun(x)} end -- (1) decorate
  table.sort(u, function(a,b) return a.y < b.y end)  -- (2) sort
  v={}; for _,xy in pairs(u) do v[1+#v] = xy.x end   -- (3) undecoreate
  return v end
-------------------------------------------------------------------------------
-- ## Coerce Strings to things

-- Coerce a string to some thing.
function lib.coerce(s)
  s = lib.trim(s)
  return math.tointeger(s) or tonumber(s) or s=="true" or (s~="false" and s) end

-- Coerce `the` from `help`.
function lib.settings(s,    t)
  t={}
  for k,s1 in s:gmatch("[-][-]([%S]+)[^=]+=[%s]*([%S]+)") do t[k] = lib.coerce(s1) end
  return t end

-- Coerce rows of a csv file to LUA tables
function lib.csv(src)
  src = src=="-" and io.stdin or io.input(src)
  return function(      s,t)
    s=io.read()
    if   s 
    then t={}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=lib.coerce(s1) end; return t
    else io.close(src) end end end

-- Coerce strings from command-line in order to update table.   
-- Non-booleans need values but booleans just flip defaults.
function lib.cli(t)
  for k, v in pairs(t) do
    v = tostring(v)
    for argv,s in pairs(arg) do
      if s=="-"..(k:sub(1,1)) or s=="--"..k then
        v = v=="true" and "false" or v=="false" and "true" or arg[argv + 1]
        t[k] = lib.coerce(v) end end end end
-------------------------------------------------------------------------------
-- ## Main functions

-- Is this script controlling the application?
function lib.isMain() return not pcall(debug.getlocal, 5, 1) end

-- Run  one of more  examples.   
-- (1) Update `the` from command line.   
-- (2) When requested, print help and quit.   
-- (3) Find relevant keys in `eg`.    
-- (4) Run that example. If it returns false, increment `bads`.     
-- (5) If running all, show final `bads` count.   
-- (6) Return the `bads` count to the operating system
function lib.main(the,eg,help,     bads)
  lib.cli(the)
  if the.help then os.exit(print(help)) end -- (1)
  bads = 0
  for _,k in pairs(lib.keys(eg)) do
    if (the.todo == k or the.todo=="all") then -- (2)
      if lib.sandbox(the, eg[k])==false then 
        io.stderr:write(lib.fmt("# !!!!!!!! FAIL [%s]\n", k ))
        bads = bads+1 end end end -- (3)
  if bads>0 and the.todo=="all" then  -- (4)
    io.stderr:write(lib.fmt("# !!!!!!!! FAIL(s) = %s\n",bads)) end
  os.exit(bads) end  -- (5)

-- Run `fun`, ensuring the config is set to defaults before and after.
function lib.sandbox(the,fun,     old,status)
  old={}; for k,v in pairs(the) do old[k]=v end
  math.randomseed(the.seed or 1234567891) -- set up
  status = fun()
  for k,v in pairs(old) do the[k]=v end -- tear down
  return status end
-------------------------------------------------------------------------------
-- Return this module.

return lib
