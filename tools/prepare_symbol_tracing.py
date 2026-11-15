"""Original printed uppercase centerline strokes; a repetition activity, not cursive instruction."""
from pathlib import Path
import math,json
R=Path(__file__).resolve().parents[1]
def arc(cx,cy,rx,ry,a,b,n=18):return [[cx+rx*math.cos(a+(b-a)*i/n),cy+ry*math.sin(a+(b-a)*i/n)] for i in range(n+1)]
def curve(p0,p1,p2,p3,n=16):return [[sum([p0[d]*(1-t)**3,3*p1[d]*(1-t)**2*t,3*p2[d]*(1-t)*t*t,p3[d]*t**3]) for d in range(2)] for t in [i/n for i in range(n+1)]]
O=arc(50,50,40,50,-math.pi/2,3*math.pi/2,24)
C=arc(50,50,40,50,-math.pi/4,-7*math.pi/4,22)
S=curve([85,12],[10,-18],[-5,48],[50,50])+curve([50,50],[110,55],[85,130],[12,88])[1:]
G={
'A':[[[10,100],[50,0],[90,100]],[[28,60],[72,60]]],
'B':[[[10,100],[10,0]],[[10,0],[50,0]]+arc(50,25,35,25,-math.pi/2,math.pi/2)[1:]+[[10,50]],[[10,50],[50,50]]+arc(50,75,35,25,-math.pi/2,math.pi/2)[1:]+[[10,100]]],
'C':[C],
'D':[[[10,100],[10,0]],[[10,0],[40,0]]+arc(40,50,50,50,-math.pi/2,math.pi/2)[1:]+[[10,100]]],
'E':[[[90,0],[10,0],[10,100],[90,100]],[[10,50],[70,50]]],
'F':[[[90,0],[10,0],[10,100]],[[10,50],[70,50]]],
'G':[C,[[90,70],[90,50],[58,50]]],
'H':[[[10,0],[10,100]],[[90,0],[90,100]],[[10,50],[90,50]]],
'I':[[[25,0],[75,0]],[[50,0],[50,100]],[[25,100],[75,100]]],
'J':[[[20,0],[85,0],[85,70]]+arc(50,70,35,30,0,math.pi)[1:]],
'K':[[[10,0],[10,100]],[[90,0],[10,55],[90,100]]],
'L':[[[10,0],[10,100],[90,100]]],
'M':[[[10,100],[10,0],[50,65],[90,0],[90,100]]],
'N':[[[10,100],[10,0],[90,100],[90,0]]],
'O':[O],
'P':[[[10,100],[10,0]],[[10,0],[50,0]]+arc(50,25,35,25,-math.pi/2,math.pi/2)[1:]+[[10,50]]],
'Q':[O,[[62,75],[95,110]]],
'R':[[[10,100],[10,0]],[[10,0],[50,0]]+arc(50,25,35,25,-math.pi/2,math.pi/2)[1:]+[[10,50]],[[50,50],[90,100]]],
'S':[S],
'T':[[[10,0],[90,0]],[[50,0],[50,100]]],
'U':[[[10,0],[10,60]]+arc(50,60,40,40,math.pi,0)[1:]+[[90,0]]],
'V':[[[10,0],[50,100],[90,0]]],
'W':[[[5,0],[25,100],[50,35],[75,100],[95,0]]],
'X':[[[10,0],[90,100]],[[90,0],[10,100]]],
'Y':[[[10,0],[50,50],[90,0]],[[50,50],[50,100]]],
'Z':[[[10,0],[90,0],[10,100],[90,100]]],
'Г':[[[10,100],[10,0],[90,0]]],
'Ґ':[[[10,100],[10,0],[90,0],[90,-18]]],
'Д':[[[0,115],[0,95],[100,95],[100,115]],[[10,95],[45,0],[60,0],[90,95]]],
'Є':[C,[[10,50],[65,50]]],
'Ж':[[[5,0],[50,50],[95,0]],[[5,100],[50,50],[95,100]],[[50,0],[50,100]]],
'З':[[[10,12],[35,0]]+arc(40,25,40,25,-math.pi/2,math.pi/2)[1:]+arc(40,75,45,25,-math.pi/2,math.pi/2)[1:]+[[10,90]]],
'И':[[[10,0],[10,100],[90,0],[90,100]]],
'І':[[[50,0],[50,100]]],
'Ї':[[[50,0],[50,100]],[[30,-18],[31,-18]],[[70,-18],[71,-18]]],
'Й':[[[10,0],[10,100],[90,0],[90,100]],arc(50,-27,25,14,math.pi,0,10)],
'Л':[[[5,100],[45,0],[60,0],[95,100]]],
'П':[[[10,100],[10,0],[90,0],[90,100]]],
'У':[[[10,0],[52,60]],[[90,0],[20,100]]],
'Ф':[arc(50,50,40,35,-math.pi/2,3*math.pi/2,24),[[50,-7],[50,107]]],
'Ц':[[[10,0],[10,100],[90,100],[90,0]],[[90,100],[90,118]]],
'Ч':[[[10,0],[10,50],[90,50]],[[90,0],[90,100]]],
'Ш':[[[10,0],[10,100],[90,100],[90,0]],[[50,0],[50,100]]],
'Щ':[[[10,0],[10,100],[90,100],[90,0]],[[50,0],[50,100]],[[90,100],[90,118]]],
'Ь':[[[10,0],[10,100]],[[10,50],[50,50]]+arc(50,75,35,25,-math.pi/2,math.pi/2)[1:]+[[10,100]]],
'Ю':[[[5,0],[5,100]],arc(65,50,30,50,-math.pi/2,3*math.pi/2,24),[[5,50],[35,50]]],
'Я':[[[90,100],[90,0],[50,0]]+arc(50,25,35,25,-math.pi/2,-3*math.pi/2)[1:]+[[90,50]],[[50,50],[10,100]]]
}
for uk,en in {'А':'A','В':'B','Е':'E','К':'K','М':'M','Н':'H','О':'O','Р':'P','С':'C','Т':'T','Х':'X'}.items():G[uk]=G[en]
G['Б']=[[[90,0],[10,0],[10,100]],[[10,45],[50,45]]+arc(50,72.5,35,27.5,-math.pi/2,math.pi/2)[1:]+[[10,100]]]
D={
'0':[O], '1':[[[25,25],[55,0],[55,100]],[[25,100],[85,100]]],
'2':[curve([10,25],[15,-15],[95,-5],[90,30])+[[10,100],[90,100]]],
'3':[[[10,10],[45,0]]+arc(45,25,40,25,-math.pi/2,math.pi/2)[1:]+arc(45,75,40,25,-math.pi/2,math.pi/2)[1:]+[[10,90]]],
'4':[[[70,0],[10,65],[95,65]],[[70,0],[70,100]]],
'5':[[[90,0],[15,0],[15,45],[50,45]]+arc(50,72.5,40,27.5,-math.pi/2,math.pi/2)[1:]+[[12,87]]],
'6':[curve([82,5],[35,-5],[10,30],[10,70])+arc(50,70,40,30,math.pi,3*math.pi,24)[1:]],
'7':[[[10,0],[90,0],[30,100]]],
'8':[arc(50,25,32,25,math.pi/2,5*math.pi/2,20),arc(50,75,40,25,-math.pi/2,3*math.pi/2,20)],
'9':[arc(50,30,40,30,0,-2*math.pi,24),curve([90,30],[90,75],[72,105],[20,95])]
}
letters=json.loads((R/'data/game_content/letters.json').read_text(encoding='utf-8'))['alphabets']
def scaled(strokes):return [[[round(x*4,2),round(y*4,2)] for x,y in path] for path in strokes]
data={'version':1,'letters':{loc:[dict(glyph=e['upper'],word_key=e['word_key'],strokes=scaled(G[e['upper']])) for e in entries] for loc,entries in letters.items()},'digits':[dict(glyph=str(i),word_key='TRACE_NUMBER_ZERO' if i==0 else 'COUNT_NUMBER_'+str(i),strokes=scaled(D[str(i)])) for i in range(10)]}
(R/'data/game_content/symbol_tracing.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
copy={'TRACE_TAB':('Trace','Обвести'),'TRACE_LETTERS':('Letters','Літери'),'TRACE_NUMBERS':('Numbers','Цифри'),'TRACE_HINT':('Follow the green dot.','Веди пальчиком за зеленою крапкою.'),'TRACE_AGAIN':('Trace again','Обвести ще раз'),'TRACE_NUMBER_ZERO':('Zero','Нуль')}
manifest=json.loads((R/'data/game_content/foundation.json').read_text(encoding='utf-8'));jobs=json.loads((R/'data/game_content/voice_jobs.json').read_text(encoding='utf-8'))
for loc,index in [('en',0),('uk',1)]:
 p=R/f'data/localization/{loc}.json';strings=json.loads(p.read_text(encoding='utf-8'))
 for key,pair in copy.items():strings[key]=pair[index]
 p.write_text(json.dumps(strings,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 for key in ['TRACE_HINT','TRACE_NUMBER_ZERO']:
  file=f'assets/audio/voice/{loc}/{key.lower()}.wav';manifest['voice'].setdefault(key,{})[loc]='res://'+file;jobs[loc]=[j for j in jobs[loc] if j['key']!=key];jobs[loc].append(dict(key=key,text=copy[key][index],file=file))
for name,value in [('foundation',manifest),('voice_jobs',jobs)]:
 (R/f'data/game_content/{name}.json').write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Printed tracing: 26 EN / 33 UK uppercase letters and digits 0-9.')
