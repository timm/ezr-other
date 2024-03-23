-- Things that are true for NUMs and SYMs

local col={}

-- Return a merge if (1) parts are well supported rare or (2) merge is not more disorderd. 
function col.merged(i,j,support,    k) 
  k = getmetatable(i)(i.txt,i.at)
  for _,thing in pairs{i,j} do
    for x,n in pairs(thing) do k:add(x,n) end end
  if i.n < (support or 0) or j.n < (support or 0) then return k end -- (1)
  if k:div() <= (i.n*i:div() + j.n*j:div())/k.n then return k end end -- (2)

return col