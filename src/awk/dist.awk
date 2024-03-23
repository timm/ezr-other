@include "strings.awk"

func cumulate(a,out,     i,all,tmp,n) {
  for(i in a) {
     tmp[++n]["x"] = i
     tmp[  n]["y"] = a[i]  
     all += a[i] }
  asort(tmp, out, "ydown") 
  for(i in out) out[i]["r"] = out[i]["y"] / all }

func ydown(_,v1,__,v2) { return compare(v2["y"], v1["y"]) }

function compare(x,y)  { return x < y ? -1 : (x == y ? 0 : 1)}

func rany(a,     r,i) {
  r=rand()
  for(i=1; i<=length(a); i++)
    if ((r -= a[i]["r"]) <=0) break;
  return a[i]["x"] }
  
func any(a) { return a[ 1+int(rand()*length(a)) ] }

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

func eg_rany(    i,a,b) {
  a["apple"]=2
  a["orange"]=1
  a["banana"]=4 
  cumulate(a,b)
  for(i=1;i<=10000;i++) print(rany(b)) | "sort | uniq -c | sort -n" }

func eg_any(    i,a,b) {
  split("apple orange banana",b, " ")
  for(i=1;i<=1000;i++) print(any(b)) | "sort | uniq -c" }

func eg_uniform(    i,a) {
  for(i=1;i<=10000;i++) a[int( uniform(1,20) )]++
  hist(a,4,50,1)  }

func eg_trig(    i,a) {
  for(i=1;i<=10000;i++) a[int( trig(1,5,20) )]++
  hist(a,4,50,1)  }

func eg_norm(    i,a) {
  for(i=1;i<=1000;i++) a[int( norm(10,2) / 1)]++
  hist(a,4,5,1) }
