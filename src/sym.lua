l=require"lib"
local SYM=l.obj"SYM"

function SYM.new(s,n)
  return {txt=s or " ", at=n or 0, n=0, has={}, mode=nil, most=0} end

print(SYM("asd",2))
return SYM
