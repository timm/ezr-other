local lib={}
-------------------------------------------------------------------------------
-- ## Strings

-- Prune leading and trailing blanks
function lib.trim(s) return s:match"^%s*(%S+)" end
-------------------------------------------------------------------------------
-- ## Tables

-- Return keys, sorted.
function lib.keys(t,    u)
  u={}; for k,_ in pairs(t) do u[1+#u]=k end; table.sort(u); return u end
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