function hist(a,  w,f,nump,    order,k) {
  order = nump ? "sort -n" : "sort" 
  f     = f    ? f         : 1
  for(k in a)
    print(sprintf("%"(w?w:4)"s | %s", k,rep(int(a[k]/f),"*"))) | order }

function rep(n,c,    s) {
  while(--n > 0) s = s c 
  return s }  

function eg_host(    a,b) {
  a["apple"]= 10
  a["juice"]= 20
  a["fred"]=  30
  hist(a,6,4) 
  b[.7]= 10
  b[1.1]= 20
  b[4.5]=  30
  hist(b,6,4,1) }
