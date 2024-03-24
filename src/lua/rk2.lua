local l,the = {},{} -- place for  (a) library functions and (b) settings
local help = [[
thing.lua
(c)2024 Tim Menzies

Options
  -f --file     data file                        = ../../data/auto93.csv
  -F --Far      if polarizing, ignore  outliners = 0.95
  -H --Halves   if polarizing, use a subset      = 64
  -l --leaf     whenrecursing, stop at n^leaf    = 0.5
  -p --p        distance coeffecient             = 2 
  -s --seed     rand seed                        = 1234567891
  -t --todo     start-up action                  = nothing ]]

-- Init stuff.  `l` are some library routines and `the` are the global vars.              
-- `isa` makes instances.       
-- `klass` defines classes. 

local function isa(x,y) return setmetatable(y,x) end
local function klass(s,    t) t={a=s}; t.__index=t; return t end
-------------------------------------------------------------------------------
-- ## NUM
-- NUMs summarize a stream of numbers.

local NUM = klass"NUM"
function NUM.new(s, n) 
  return isa(NUM, {n=0, txt=s, at=n, mu=0, lo=1E30, hi=-1E30}) end

-- update
function NUM:add(x,    d) 
  if x~="?" then
    self.n  = self.n + 1 
    self.lo = math.min(x, self.lo)
    self.hi = math.max(x, self.hi) 
    d       = x - self.mu
    self.mu = self.mu + d/self.n end end

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

-- Maps `x` 0->1 for lo->hi.
function NUM:norm(x) 
  return x=="?" and x or (x - self.lo)/(self.hi - self.lo + 1E-30) end
-------------------------------------------------------------------------------
-- ## SYM
-- SYMs summarize a stream of symbols

local SYM = klass"SYM"
function SYM.new(s, n)
  return isa(SYM, {n=0, txt=s, at=n, has={}}) end

function SYM:add(x)  
  if x~="?" then
    self.n = self.n + 1
    self.has[x] = (self.has[x] or 0) + 1 end end

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

local COLS = klass"COLS"
function COLS.new(t,     x,y,all,col,klass)
  all,x,y = {},{},{}
  for n,s in pairs(t) do
    col = l.push(all, (s:find"^[A-Z]" and NUM or SYM).new(s,n))
    if not s:find"X$" then
      l.push( s:find"[!+-]" and y or x, col)
      if s:find"!$" then klass = col end end end
  return isa(COLS, {names=t; all=all, x=x, y=y, klass=klass}) end

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

local DATA = klass"DATA"
function DATA.new(src,    self)
  self = isa(DATA, {rows={}, cols={}})
  if type(src)=="function" then for   t in src        do self:add(t) end end
  if type(src)=="table"    then for _,t in pairs(src) do self:add(t) end end
  return self end

-- Update
function DATA:add(t)
  if   #self.cols > 0
  then l.push(self.rows, self.cols:add(t) )
  else self.cols = COLS.new(t) end end

-- Return another DATA with the same structure.
function DATA:clone(  t,d)
  d = DATA.new({self.cols.names})
  for _,t1 in pairs(t or {}) do d:add(t1) end
  return d end

-- Stats
function DATA:mid(  cols,ndecs,    u)
  u={}; for _,col in pairs(cols or self.cols.y) do 
          u[1+#u]= l.rnd(col:mid(),ndecs) end; return u end

-- Distance.
function DATA:dist(t1,t2,      n,d)
  n,d = 0,0
  for _,col in pairs(self.cols.x) do
    n = n + 1
    d = d + col:dist(t1[col.at], t2[col.at])^the.p end
  return (d/n)^(1/the.p) end

function DATA:neighbors(row1,  rows)
  return l.keysort(rows or self.rows,
                   function(row2) return self:dist(row1,row2) end) end

-- Returns two distance points.
function DATA:polarize(rows,      east,west,far)
  rows = rows or self.rows
  far = (#rows * the.Far)//1
  east = self:neighbors(l.any(rows),rows)[far]
  west = self:neighbors(east,rows)[far]
  return east,west,self:dist(east,west) end

-- Divides rows by their distance to two distant points.
function DATA:halve(rows,      east,_,easts,wests,c)
  east, _,c = self:polarize(l.many(rows, the.Halves))
  easts,wests = {},{}
  for _,t in pairs(rows) do
    l.push(self:dist(t,east) <= c/2 and easts or wests, t) end
  return easts, wests end

-- Recursive bi-cluster the data. 
function DATA:halves(rows,lvl,     node,lefts,rights)
  lvl = lvl or 0
  rows  = rows or self.rows 
  node = {here=self:clone(rows)}
  if   #rows > 2*(#self.rows)^the.leaf
  then  print( (('|.. '):rep(lvl)..(#rows)))
        lefts,rights = self:halve(rows) 
        node.left  = #lefts < #rows and self:k2means(lefts,lvl+1)
        node.right = #rights < #rows and self:k2means(rights,lvl+1)
  else  print( (('|.. '):rep(lvl)..(#rows)),":", l.o(node.here:mid()))
  return node end end
-------------------------------------------------------------------------------
-- ## Misc library functions

function l.push(t,x) t[1+#t] = x; return x end

function l.sort(t,fun) table.sort(t,fun); return t end

function l.any(a) return a[math.random(#a)] end

function l.many(a,n,   u)
  u={}; for i=1,n do u[1+#u] = l.any(a) end; return u end; 

function l.keys(t,    u)
  u={}; for k,_ in pairs(t) do u[1+#u]=k end; table.sort(u); return u end

function l.keysort(t,fun,      u,v)
  u={}
  for _,x in pairs(t) do u[1+#u]={x=x, y=fun(x)} end
  table.sort(u, function(a,b) return a.y < b.y end)
  v={}; for _,xy in pairs(u) do v[1+#v] = xy.x end
  return v end

function l.rnd(n, ndecs,     mult)
  if type(n) ~= "number" then return n end
  if math.floor(n) == n  then return n end
  mult = 10^(ndecs or 2)
  return math.floor(n * mult + 0.5) / mult end

function l.coerce(s)
  return math.tointeger(s) or tonumber(s) or s=="true" or (s~="false" and s) end

function l.csv(src)
  src = src=="-" and io.stdin or io.input(src)
  return function(      s,t)
    s=io.read()
    if   s
    then t={}; for s1 in s:gsub("%s+", ""):gmatch("([^,]+)") do t[1+#t]=l.coerce(s1) end
         return t
    else io.close(src) end end end

function l.cli(t)
  for k, v in pairs(t) do
    v = tostring(v)
    for n,s in pairs(arg) do
      if s=="-"..k:sub(1,1) then
        v = v=="true" and "false" or v=="false" and "true" or arg[n + 1]
        t[k] = l.coerce(v) end end end end 

function l.oo(t) print(l.o(t)) end

function l.o(t,    u)
  u={}
  for _,k in pairs(l.keys(t)) do
    u[1+#u] = #t>0 and tostring(t[k]) or string.format(":%s %s",k,t[k]) end
  return table.concat(#t>0 and u or l.sort(u), ", ") end
-------------------------------------------------------------------------------
local eg={}

function eg.seed() print(the.seed) end

function eg.data(     d)
  d = DATA.new(l.csv(the.file))
  l.oo(d:mid(3)) end

function eg.clone(     d)
   d = DATA.new(l.csv(the.file))
   d:clone(d.rows) end

function eg.dists(    d,a,b,ab)
  d = DATA.new(l.csv(the.file))
  for _,row in pairs(d.rows) do io.write(l.rnd(d:dist(row, d.rows[1]),3)," ") end end

function eg.sort(    d,rows)
  d = DATA.new(l.csv(the.file))
  rows = d:around(d.rows[1]) 
  print("id,",l.o(d.cols.names))
  for i=1,10    do print(i..",",l.o(rows[i])) end
  for i=370,380 do print(i..",",l.o(rows[i])) end end

function eg.halves(  d)
  DATA.new(l.csv(the.file)):halves() end
-----------------------------------------
-- Start up. 

-- Parse out help to make `the`.   
for k, s in help:gmatch("[-][-]([%S]+)[^=]+=[%s]+([%S]+)") do 
  the[k] = l.coerce(s) end

-- Update `the` from command line.     
-- Seed seed from `the`.
l.cli(the)
math.randomseed(the.seed)

-- Do something
if eg[the.todo] then eg[the.todo]() end