#!/usr/bin/env lua

local l,the = {},{}-- place for  (a) library functions and (b) settings
local help = [[
thing.lua
(c)2024 Tim Menzies

Options
  -f --file     data file                        = ../../data/auto93.csv
  -F --Far      if polarizing, ignore  outliners = 0.95
  -H --Halves   if polarizing, use a subset      = 128
  -l --leaf     when recursing, stop at n^leaf   = 0.5
  -L --lhs      tree print left hand side        = 35
  -p --p        distance coeffecient             = 2 
  -s --seed     rand seed                        = 1234567891
  -t --todo     start-up action                  = nothing ]]
-- Coding note: In my function headers, 2/4 spaces denote optional/local args.

-------------------------------------------------------------------------------
-- ## NUM

-- NUMs summarize a stream of numbers.
local NUM = {}
function NUM.new(  s,n)
  return l.isa(NUM, {n=0, txt=s, at=n, mu=0, lo=1E30, hi=-1E30,
                     heaven= (s or ""):find"-$" and 0 or 1}) end

-- update
function NUM:add(x,    d) 
  if x~="?" then
    self.n  = self.n + 1 
    self.lo = math.min(x, self.lo)
    self.hi = math.max(x, self.hi) 
    d       = x - self.mu
    self.mu = self.mu + d/self.n end end

function NUM.merge(i,j,    new)
  new    = NUM.new(i.txt,i.s)
  new.n  = i.n + j.n
  new.mu = (i.n*i.mu + j.n*j.mu) / (new.n + 1E-30)
  new.lo = math.min(i.lo, j.lo)
  new.hi = math.max(i.hi, j.hi)
  return new end

-- Stats.
function NUM:mid() return self.mu end
function NUM:div() return (self.hi - self.lo) / 2.56 end

-- Distance.
function NUM:dist(x,y)
  if x=="?" and y=="?" then return 1 end
  x, y = self:norm(x), self:norm(y)
  if x=="?" then x = y<.5 and 1 or 0 end
  if y=="?" then y = x<.5 and 1 or 0 end
  return math.abs(x-y) end

-- Maps `x` 0..1 for lo..hi.
function NUM:norm(x) 
  return x=="?" and x or (x - self.lo)/(self.hi - self.lo + 1E-30) end
-------------------------------------------------------------------------------
-- ## SYM

-- SYMs summarize a stream of symbols
local SYM = {}
function SYM.new(s, n)
  return l.isa(SYM, {n=0, txt=s, at=n, has={}}) end

function SYM:add(x)
  if x~="?" then
    self.n = self.n + 1
    self.has[x] = (self.has[x] or 0) + 1 end end

function SYM.merge(i,j,      new)
  new = SYM.new(i.txt, i.at)
  new.n = i.n + j.n
  for _,has in pairs{i.has, j.has} do
    for k,v in pairs(has) do
      new.has[k] = (new.has[k] or 0) + v end end
  return new end

function SYM:mid(    n,mode)
  n=0; for k,v in pairs(self.has) do if v>n then mode,n=v,n end end; return mode end

function SYM:div(     e)
  e=0; for _,v in pairs(self.has) do e=e + v/self.n*math.log(v/self.n,2) end
  return -e end

function SYM:dist(x,y)
  return x=="?" and y=="?" and 1 or (x==y and 0 or 1) end
-------------------------------------------------------------------------------
-- ## COLS

-- Factory to make column headers (from column names).
local COLS = {}
function COLS.new(t,     x,y,all,col,klass)
  all,x,y = {},{},{} 
  for n,s in pairs(t) do
    col = l.push(all, (s:find"^[A-Z]" and NUM or SYM).new(s,n))
    if not col.txt:find"X$" then
      l.push(col.txt:find"[!+-]" and y or x, col)
      if col.txt:find"!$" then klass = col end end end
  return l.isa(COLS, {names=t; all=all, x=x, y=y, klass=klass}) end

-- Update
function COLS:add(t)
  for _,cols in pairs{self.x, self.y} do
    for _,col in pairs(cols) do
      col:add( t[col.at] ) end end 
  return t end
-------------------------------------------------------------------------------
-- ## DATA

-- Store `rows` and their `col`umn summaries.
-- DATA can be initialized from a csv file or a list of rows.
local DATA = {}
function DATA.new(src,order,    self)
  self = l.isa(DATA, {rows={}, cols=nil})
  if type(src)=="function" then for   t in src        do self:add(t) end end
  if type(src)=="table"    then for _,t in pairs(src) do self:add(t) end end
  if order then self:sort() end
  return self end

-- Update
function DATA:add(t)
  if   self.cols
  then l.push(self.rows, self.cols:add(t) )
  else self.cols = COLS.new(t) end end

function DATA:sort()
  self.rows = l.keysort(self.rows, function(row) return self:d2h(row) end)
  return self.rows end

-- Merge
function DATA.merge(i,j,     new)
  new = i:clone{}
  for n,col0 in pairs(new.cols.all) do
    for k,v in pairs(i.cols.all[n]:merge(j.cols.all[n])) do
      col0[k] = v end end
  for _,rows in pairs{i.rows,j.rows} do
    for _,row in pairs(rows) do
      l.push(new.rows, row) end end
  return new end

-- Return another DATA with the same structure.
function DATA:clone(  t,order,        d)
  d = DATA.new({self.cols.names})
  for _,t1 in pairs(t or {}) do d:add(t1) end
  if order then d:sort() end
  return d end

-- Stats
function DATA:mid(  cols,ndecs,    u) 
  u={}; for _,col in pairs(cols or self.cols.y) do 
          u[1+#u]= l.rnd(col:mid(),ndecs) end; return u end

-- Distance between two rows.
function DATA:dist(t1,t2,      n,d)
  n,d = 0,0
  for _,col in pairs(self.cols.x) do
    n = n + 1
    d = d + col:dist(t1[col.at], t2[col.at])^the.p end
  return (d/n)^(1/the.p) end

-- Distance from a row to a best values for all `y` goals.
function DATA:d2h(t,     n,d)
  n,d = 0,0
  for _,col in pairs(self.cols.y) do
    n = n + 1
    d = d + math.abs(col:norm(t[col.at]) - col.heaven)^2 end
  return (d/n)^(1/2) end

-- Sort everything in `rows` (defaults to `self.rows`) by distance to `row1`.
function DATA:neighbors(row1,  rows)
  return l.keysort(rows or self.rows,
                   function(row2) return self:dist(row1,row2) end) end

-- Returns two distance points.
function DATA:polarize(rows,      p,q,far)
  rows = rows or self.rows
  far  = (#rows * the.Far)//1
  p    = self:neighbors(l.any(rows),rows)[far]
  q    = self:neighbors(p,rows)[far]
  return p,q,self:dist(p,q) end

-- Divides rows by distance to two distant points. Return biggest division first.
function DATA:halve(rows,  order,     p,q,ps,qs,c)
  p,q,c = self:polarize(l.many(rows, the.Halves))
  ps,qs = {},{}
  for _,t in pairs(rows) do
    l.push(self:dist(t,p) <= c/2 and ps or qs, t) end
  if order
  then if self:d2h(q) < self:d2h(p) then ps,qs,p,q = qs,ps,q,p end
  else if #ps < #qs                 then ps,qs,p,q = qs,ps,q,p end end
  return ps,qs end

-- Recursively bi-cluster the data. 
function DATA:halves(rows,order,     node,ps,qs,stop) 
  rows = rows or self.rows 
  node = {here=self:clone(rows,true)}
  stop = (#self.rows)^the.leaf
  if #rows > stop
  then  ps,qs = self:halve(rows, order)
        node.lefts  = #ps < #rows and self:halves(ps, order) 
        node.rights = #qs < #rows and self:halves(qs, order) end
  return node end

function DATA:visit(node,fun,      lvl)
  lvl = lvl or 0
  if node then
    fun(self,node,lvl)
    for _,kid in pairs{node.lefts, node.rights} do
      self:visit(kid, fun, lvl+1) end end end

function DATA:show(it,lvl,      right,left)
  right = (it.lefts or it.rights) and "" or " : "..l.o(it.here.rows[1])  --mid())
  left  = ('|.. '):rep(lvl)..#(it.here.rows)
  print(string.format("%-" .. the.lhs .. "s %s", left, right)) end 

-------------------------------------------------------------------------------
-- ## Misc library functions
-- ### Objects

-- Make classes.  
function l.klassify(t)
  for s,klass in pairs(t) do klass.a=s; klass.__index=klass end end

-- Make an instance. 
function l.isa(x,y) return setmetatable(y,x) end

-- ### Lists

-- Return `x` after adding it to end of `t`.
function l.push(t,x) t[1+#t] = x; return x end

-- Return any one item from `t`.
function l.any(t) return t[math.random(#t)] end

-- Return any `n` items from `t`.
function l.many(t,n,   u)
  u={}; for i=1,n do u[1+#u] = l.any(t) end; return u end; 

-- Return `t` skipping `go` to `stop` in steps of `inc`.
function l.slice(t, go, stop, inc,    u)
  if go   and go   < 0 then go=#t+go     end
  if stop and stop < 0 then stop=#t+stop end
  u={}
  for j=(go or 1)//1,(stop or #t)//1,(inc or 1)//1 do u[1+#u]=t[j] end
  return u end

-- ### Sorting 

-- Return `t` after sorting it according to `fun`.
function l.sort(t,fun) table.sort(t,fun); return t end

-- Return the keys of `t`, sorted.
function l.keys(t,    u)
  u={}; for k,_ in pairs(t) do u[1+#u]=k end; table.sort(u); return u end

-- Sort using the Schwartzian transform (decorete, sort, undecorate).
function l.keysort(t,fun,      u,v)
  u={}
  for _,x in pairs(t) do u[1+#u]={x=x, y=fun(x)} end
  table.sort(u, function(a,b) return a.y < b.y end)
  v={}; for _,xy in pairs(u) do v[1+#v] = xy.x end
  return v end

-- ### Maths

-- Round something to `ndecs` or, if its an int, to no decimals.
function l.rnd(n, ndecs,     mult)
  if type(n) ~= "number" then return n end
  if math.floor(n) == n  then return n end
  mult = 10^(ndecs or 2)
  return math.floor(n * mult + 0.5) / mult end

-- ### String to Thing

-- Convert string to thing.
function l.coerce(s)
  return math.tointeger(s) or tonumber(s) or s=="true" or (s~="false" and s) end

-- Convert help strings (like as seen above) to key:values of a table. 
function l.options(t,s)
  for k, s in s:gmatch("[-][-]([%S]+)[^=]+=[%s]+([%S]+)") do t[k] = l.coerce(s) end end

-- Iterator. Convert strings in a csv file as Lua tables, one table at a time. 
function l.csv(src)
  src = src=="-" and io.stdin or io.input(src)
  return function(      s,t)
    s=io.read()
    if   s
    then t={}; for s1 in s:gsub("%s+", ""):gmatch("([^,]+)") do t[1+#t]=l.coerce(s1) end
         return t
    else io.close(src) end end end

-- Convert command-line strings to update to table `t`. 
function l.cli(t)
  for k, v in pairs(t) do
    v = tostring(v)
    for n,s in pairs(arg) do
      if s=="-"..k:sub(1,1) then
        v = v=="true" and "false" or v=="false" and "true" or arg[n + 1]
        t[k] = l.coerce(v) end end end end

-- ### Thing to Strings

-- Convert thing to string and print it.
function l.oo(t) print(l.o(t)) end

-- Convert thing to string.
function l.o(t,    u)
  u={}
  for _,k in pairs(l.keys(t)) do
    u[1+#u] = #t>0 and tostring(t[k]) or string.format("%s:%s",k,t[k]) end
  return (t.a or "") .. "{" .. table.concat(#t>0 and u or l.sort(u), ", ") .. "}" end
-------------------------------------------------------------------------------
-- ## Start-up Actions

local eg={}

function eg.the() l.oo(the) end

function eg.seed() print(the.seed) end

function eg.data(     d)
  d = DATA.new(l.csv(the.file))
  l.oo(d:mid(d.cols.all,3)) end

function eg.clone(     d)
   d = DATA.new(l.csv(the.file))
   d:clone(d.rows) end

function eg.dists(    d,a,b,ab)
  d = DATA.new(l.csv(the.file))
  for _,row in pairs(d.rows) do io.write(l.rnd(d:dist(row, d.rows[1]),3)," ") end end

function eg.neighbors(    d,rows)
  d = DATA.new(l.csv(the.file))
  rows = d:neighbors(d.rows[1]) 
  print("id,",l.o(d.cols.names))
  for i=1,7     do print(i..",",l.o(rows[i])) end
  for i=373,380 do print(i..",",l.o(rows[i])) end end

function eg.sort()
  d = DATA.new(l.csv(the.file),true)
  for i=1,#d.rows,25 do
    l.oo(d.rows[i]) end end

function eg.halves(       d, tree)
  d    = DATA.new(l.csv(the.file))
  tree = d:halves(d.rows, true)
  d:visit(tree,DATA.show) end
 
function eg.merge(       d,d1,d2,t1,t2,d3)
  d     = DATA.new(l.csv(the.file))
  t1,t2 = l.slice(d.rows,1,200), l.slice(d.rows,200)
  d1,d2 = d:clone(t1), d:clone(t2)
  d3    = d1:merge(d2)
  for i,_ in pairs(d.cols.all) do print""
    l.oo(d.cols.all[i])
    l.oo(d3.cols.all[i]) end end

-----------------------------------------
-- ## Start up. 

-- Enable methods in classes.
l.klassify{NUM=NUM,SYM=SYM,DATA=DATA,COLS=COLS}

-- Parse `help` to make `the.    
-- Update `the` from the command line.  
-- Seed seed from `the`.
l.options(the,help)
l.cli(the)
math.randomseed(the.seed)

-- Do something
if eg[the.todo] then eg[the.todo]() end