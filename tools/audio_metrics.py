"""Simple per-clip periodicity screen; does not recognize words."""
import array,math,wave
def measure(path):
 with wave.open(str(path),'rb') as f:rate=f.getframerate();samples=array.array('h',f.readframes(f.getnframes()))
 signal=list(samples[::3]);hz=rate/3;length=int(hz*.030);hop=int(hz*.010);peak=max(map(abs,signal));active=voiced=0;maximum=0
 for offset in range(0,len(signal)-length,hop):
  frame=signal[offset:offset+length];mean=sum(frame)/length;frame=[v-mean for v in frame];energy=sum(v*v for v in frame)
  if math.sqrt(energy/length)<max(80,peak*.035):continue
  active+=1;best=0
  for lag in range(int(hz/380),int(hz/115)):
   a=frame[:-lag];b=frame[lag:];denom=math.sqrt(sum(v*v for v in a)*sum(v*v for v in b))
   if denom:best=max(best,sum(x*y for x,y in zip(a,b))/denom)
  maximum=max(maximum,best)
  if best>.68:voiced+=1
 return dict(seconds=round(len(samples)/rate,3),active_ms=active*10,voiced_ms=voiced*10,voiced_fraction=round(voiced/max(1,active),3),max_periodicity=round(maximum,3),review=voiced<10)
