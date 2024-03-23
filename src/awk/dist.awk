@include "strings.awk"

func cummulate(a,out,   b,n) {
  for(x in a) {
     b[length(b)+1]["x"] = i
     b[length(b)  ]["y"] = a[i]  
     all += a[i]
  n=asort(b, out,"ydown") 
  for(i out) out[i]["r"] = out[i]["y"] / n }

func ydown(_,v1,__,v2) { return compare(v2["y"], v1["y"]) }

function compare(x,y)  { return (x < y) ? -1 : (x == y ? 0 : 1)}

func biased(a,     r) {
  r=rand()
  for(i=1; i<=length(a); i++)
    if (r -= a[i]["r"])
  
func any(a) { return a[ int(.5 + rand()*length(a) ] }

func norm(mu,sd) {
  mu = mu ? mu : 0
  sd = sd ? sd : 1
  return mu + sd  * (-2 * log(rand()))^.5 * cos(2 * 3.14159 * rand()) }

func uniform(lo,hi) {
  return lo + rand()*(hi-lo) }

func trig(lo,mid,hi,   u) {
  u = rand()
  return (u<(mid-lo)/(hi-lo)) ? lo+(u*(hi-lo)*(mid-lo))^0.5  \
                              : hi-((1-u)*(hi-lo)*(hi-mid))^0.5 }

func eg_any(    i,a,b) {
  for(i=1;i<=20   ;i++) b[i]=i
  for(i=1;i<=10;i++) print any(b)
  #for(i in a) print(i,a[i])
  #hist(a,4,50,0)  }
  }

func eg_uniform(    i,a) {
  for(i=1;i<=10000;i++) a[int( uniform(1,20) )]++
  hist(a,4,50,1)  }

func eg_trig(    i,a) {
  for(i=1;i<=10000;i++) a[int( trig(1,5,20) )]++
  hist(a,4,50,1)  }

func eg_norm(    i,a) {
  for(i=1;i<=1000;i++) a[int( norm(10,2) / 1)]++
  hist(a,4,5,1) }
