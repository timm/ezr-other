local l={}


-------------------------------------------------------------------------------
-- ## Strings

-- Prune leading and trailing blanks
function l.trim(s) return s:match"^%s*(%S+)" end
-------------------------------------------------------------------------------
-- ## Tables

-- Return keys, sorted.
function l.keys(t,    u)
  u={}; for k,_ in pairs(t) do u[1+#u]=k end; table.sort(u); return u end
-------------------------------------------------------------------------------
-- ## Coerce Strings to things

-- Coerce a string to some thing.
function l.coerce(s)
  s = l.trim(s)
  return math.tointeger(s) or tonumber(s) or s=="true" or (s~="false" and s) end

-- Coerce `the` from `help`.
function l.settings(s,    t)
  t={}
  for k,s1 in s:gmatch("[-][-]([%S]+)[^=]+=[%s]*([%S]+)") do t[k] = l.coerce(s1) end
  return t end

-- Coerce rows of a csv file to LUA tables
function l.csv(src)
  src = src=="-" and io.stdin or io.input(src)
  return function(      s,t)
    s=io.read()
    if   s 
    then t={}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=l.coerce(s1) end; return t
    else io.close(src) end end end

-- Coerce strings from command-line in order to update table.   
-- Non-booleans need values but booleans just flip defaults.
function l.cli(t)
  for k, v in pairs(t) do
    v = tostring(v)
    for argv,s in pairs(arg) do
      if s=="-"..(k:sub(1,1)) or s=="--"..k then
        v = v=="true" and "false" or v=="false" and "true" or arg[argv + 1]
        t[k] = l.coerce(v) end end end end
-------------------------------------------------------------------------------
-- ## Main functions

-- Is this script controlling the application?
function l.isMain() return not pcall(debug.getlocal, 5, 1) end

-- Run all examples
function l.main(the,eg,help,     bads)
  l.cli(the)
  if the.help then os.exit(print(help)) end
  bads = 0
  for _,k in pairs(l.keys(eg)) do
    if (the.todo == k or the.todo=="all") and l.reset(the, eg[k])==false then
      io.stderr:write(l.fmt("# !!!!!!!! FAIL [%s]\n", k ))
      bads = bads+1 end end
  if bads>0 and the.todo=="all" then 
    io.stderr:write(l.fmt("# !!!!!!!! FAIL(s) = %s\n",bads)) end
  os.exit(bads) end

-- Run `fun`, ensuring the config is set to defaults before and after.
function l.reset(the,fun,     old,status)
  old={}; for k,v in pairs(the) do old[k]=v end
  math.randomseed(the.seed or 1234567891) -- set up
  status = fun()
  for k,v in pairs(old) do the[k]=v end -- tear down
  return status end

-------------------------------------------------------------------------------
-- Return this module.

return l