local l,the = {},{file = "../../data/auto93.csv",
                  Far  = 0.9,
                  k    = 23,
                  leaf = 0.5,
                  m    = 32,
                  p    = 2,
                  seed = 1234567891,
                  todo = "nothing"}

local function isa(x,y) return setmetatable(y,x) end
local function klass(s,    t) t={a=s}; t.__index=t; return t end

-------------------------------------------------------------------------------
local NUM = klass"NUM"
function NUM.new(s, n) return isa(NUM, {n=0, txt=s, at=n, mu=0, lo=1E30, hi=-1E30}) end

function NUM:add(x,    d) 
  if x~="?" then
    self.n  = self.n + 1 
    self.lo = math.max(x, self.lo)
    self.hi = math.max(x, self.hi) 
    d       = x - self.mu
    self.mu = self.mu + d/self.n end end

function NUM:mid() return self.mu end
function NUM:div() return (self.hi - self.lo) / 2.56 end

function NUM:dist(x,y)
  if x=="?" and y=="?" then return 1 end
  x, y = self:norm(x), self:norm(y)
  if x=="?" then x = y<.5 and 1 or 0 end
  if y=="?" then y = x<.5 and 1 or 0 end
  return math.abs(x-y) end

function NUM:norm(x)
  return x=="?" and x or (x - self.lo)/(self.hi - self.lo + 1E-30) end

-------------------------------------------------------------------------------
local SYM = klass"SYM"
function SYM.new(s, n) return isa(SYM, {n=0, txt=s, at=n, has={}}) end

function SYM:add(x)  
  if x~="?" then
    self.n = self.n + 1
    self.has[x] = (self.has[x] or 0) + 1 end end

function SYM:mid(    n,mode)
  n=0; for k,v in pairs(self.has) do if v>n then mode,n=v,n end end; return mode end

function SYM:div(     e)
  e=0; for _,v in pairs(self.has) do e=e + v/self.n*math.log(v/self.n,2) end; return -e end

function SYM:dist(x,y)
  return x=="?" and y=="?" and 1 or (x==y and 0 or 1) end
-------------------------------------------------------------------------------
local COLS = klass"COLS"
function COLS.new(t,     x,y,all,col,klass)
  all,x,y = {},{},{}
  for n,s in pairs(t) do
    col = l.push(all, (s:find"^[A-Z]" and NUM or SYM).new(s,n))
    if not s:find"X$" then
      l.push( s:find"[!-+]" and y or x, col)
      if s:find"!$" then klass = col end end end
  return isa(COLS, {names=t; all=all, x=x, y=y, klass=klass}) end

function COLS:add(t)
  for _,cols in pairs{self.x, self.y} do
    for _,col in pairs(cols) do
      col:add( t[col.at] ) end end 
  return t end

-------------------------------------------------------------------------------
local DATA = klass"DATA"
function DATA.new(src,    self)
  self = isa(DATA, {rows={}})
  if   type(src) == "function"
  then for t   in src        do self:add(t) end
  else for _,t in pairs(src) do self:add(t) end end
  return self end

function DATA:add(t)
  if   self.cols 
  then l.push(self.rows, self.cols:add(t) )
  else self.cols = COLS.new(t) end end

function DATA:clone(  t,d)
  d = DATA.new({self.cols.names})
  for _,t1 in pairs(t or {}) do d:add(t1) end
  return d end

function DATA:mid(   ndecs,    u)
  u={}; for _,col in pairs(self.cols.all) do 
          u[col.txt]= l.rnd(col:mid(),ndecs) end; return u end

function DATA:dist(t1,t2,      n,d)
  n,d = 0,0
  for _,col in pairs(self.cols.x) do
    n = n + 1
    d = d + col:dist(t1[col.at], t2[col.at])^the.p end
  return (d/n)^(1/the.p) end

function DATA:around(row1,  rows)
  return l.keysort(rows or self.rows,
                   function(row2) return self:dist(row1,row2) end) end

function DATA:polarize(rows,      a,b,d)
  rows = rows or self.rows
  d=-1
  for i=1,30 do
    local a0,b0 = l.any(rows), l.any(rows)
    local d0 = self:dist(a0,b0)
    print(d0)
    if d0 ~= 0 and d0 > d then a,b,d = a0,b0,d0 end end
  print("::",a,b)
  print("::",l.o(a),l.o(b))
  return a,b end

function DATA:halve(rows,      left,right,lefts,rights)
  left, right = self:polarize(rows)
  lefts,rights = {},{}
  for _,t in pairs(rows) do
    l.push(self:dist(t,left) < self:dist(t,right) and lefts or rights, t) end
  return lefts, rights end

function DATA:k2means(rows,lvl,     node,lefts,rights)
  lvl = lvl or 0
  rows  = rows or self.rows 
  node = {here=self:clone(rows)}
  if   #rows > 2*(#self.rows)^the.leaf
  then lefts,rights = self:halve(rows) 
       node.left  = #lefts < #rows and self:k2means(lefts,lvl+1)
       node.right = #rights < #rows and self:k2means(rights,lvl+1)
  return node end end

-------------------------------------------------------------------------------
function l.push(t,x) t[1+#t] = x; return x end

function l.sort(t,fun) table.sort(t,fun); return t end

function l.any(a,  i) i=math.random(#a); return a[i] end

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
  for i=1,20 do
    print""
    a= l.any(d.rows)
    b= l.any(d.rows)
    ab= d:dist(a,b)
    print(l.o(a))
    print(l.o(b))
    print(ab) end end

function eg.sort(    d,rows)
  d = DATA.new(l.csv(the.file))
  rows = d:around(d.rows[1]) 
  print("id,",l.o(d.cols.names))
  for i=1,10    do print(i..",",l.o(rows[i])) end
  for i=370,380 do print(i..",",l.o(rows[i])) end end

function eg.k2means(  d)
  DATA.new(l.csv(the.file)):k2means() end
-----------------------------------------
l.cli(the)
math.random(the.seed)
if eg[the.todo] then eg[the.todo]() end
