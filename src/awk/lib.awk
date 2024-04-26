## Sorting
# Sort descending by "y"
function ydown(_,v1,__,v2) { return compare(v2["y"], v1["y"]) }

# Gawk's generic sort routine.
function compare(x,y)  { return x < y ? -1 : (x == y ? 0 : 1)}

function coerce(s,    t) { t=s+0; return s==t ? t : s }