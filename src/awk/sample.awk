@include "lib.awk"
@include "strings.awk"

function cumulate(a,out,     i,all,tmp,n) {
  for(i in a) {
     tmp[++n]["x"] = i;
     tmp[  n]["y"] = a[i] ; 
     all += a[i] }
  asort(tmp, out, "ydown");
  for(i in out) out[i]["r"] = out[i]["y"] / all }

function rany(a,     r,i) {
  r=rand();
  for(i=1; i<=length(a); i++)
    if ((r -= a[i]["r"]) <=0) break;
  return a[i]["x"] }
  
function any(a) { return a[ 1+int(rand()*length(a)) ] }

function norm(mu,sd) {
  mu = mu ? mu : 0;
  sd = sd ? sd : 1;
  return mu + sd  * (-2 * log(rand()))^.5 * cos(2 * 3.14159 * rand()) }

function uniform(lo,hi) {
  return lo + rand()*(hi-lo) }

function trig(lo,mid,hi,   u) {
  u = rand();
  return (u<(mid-lo)/(hi-lo)) ? lo+(u*(hi-lo)*(mid-lo))^0.5  \
                              : hi-((1-u)*(hi-lo)*(hi-mid))^0.5 }

function eg_rany(    i,a,b) {
  a["apple"]=2;
  a["orange"]=1;
  a["banana"]=4;
  cumulate(a,b);
  for(i=1;i<=10000;i++) print(rany(b)) | "sort | uniq -c | sort -n" }

function eg_any(    i,a,b) {
  split("apple orange banana",b, " ");
  for(i=1;i<=1000;i++) print(any(b)) | "sort | uniq -c" }

function eg_uniform(    i,a) {
  for(i=1;i<=10000;i++) a[int( uniform(1,20) )]++;
  hist(a,4,50,1)  }

function eg_trig(    i,a) {
  for(i=1;i<=10000;i++) a[int( trig(1,5,20) )]++;
  hist(a,4,50,1)  }

function eg_norm(    i,a) {
  for(i=1;i<=1000;i++) a[int( norm(10,2) / 1)]++;
  hist(a,4,5,1) }
