"""Original SVG story art using the existing companions' palette and facial language."""
import json,math
from pathlib import Path
R=Path(__file__).resolve().parents[1]
OUT=R/'assets/illustrations/stories';OUT.mkdir(parents=True,exist_ok=True)
DEFS='''<defs>
<linearGradient id="cream" x2=".3" y2="1"><stop stop-color="#fff7df"/><stop offset="1" stop-color="#edcda2"/></linearGradient>
<linearGradient id="fur" x2=".2" y2="1"><stop stop-color="#eac18a"/><stop offset="1" stop-color="#ce935e"/></linearGradient>
<linearGradient id="rust" x2=".3" y2="1"><stop stop-color="#b38768"/><stop offset="1" stop-color="#805d4c"/></linearGradient>
<linearGradient id="leaf" x2=".3" y2="1"><stop stop-color="#b6d49b"/><stop offset="1" stop-color="#72a780"/></linearGradient>
<linearGradient id="blue" x2=".2" y2="1"><stop stop-color="#c9e5ec"/><stop offset="1" stop-color="#82b8cf"/></linearGradient>
<linearGradient id="pink" x2=".3" y2="1"><stop stop-color="#f4c3ca"/><stop offset="1" stop-color="#d995ab"/></linearGradient>
<linearGradient id="gold" x2=".2" y2="1"><stop stop-color="#ffe8a1"/><stop offset="1" stop-color="#e8b455"/></linearGradient>
<linearGradient id="cloud" x2=".3" y2="1"><stop stop-color="#fffef5"/><stop offset="1" stop-color="#dbe9e9"/></linearGradient>
<linearGradient id="autumn" x2=".2" y2="1"><stop stop-color="#efc084"/><stop offset="1" stop-color="#cb855e"/></linearGradient>
</defs>'''
def ellipse(x,y,rx,ry,fill,opacity=1):return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" opacity="{opacity}"/>'
def path(d,fill,stroke='',width=3):return f'<path d="{d}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"' if stroke else '')+'/>'
def rect(x,y,w,h,fill,r=12):return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}"/>'
def face(x,y,s=1):
 return f'<g transform="translate({x} {y}) scale({s})">'+ellipse(-22,0,7,10,'#293d39')+ellipse(22,0,7,10,'#293d39')+ellipse(-24,-3,2.5,3,'#fffdf4')+ellipse(20,-3,2.5,3,'#fffdf4')+ellipse(-36,18,10,5,'#e6a89b',.6)+ellipse(36,18,10,5,'#e6a89b',.6)+path('M-11 24Q0 34 11 24','none','#986e5b',3)+'</g>'
def shadow(y=276,rx=83):return ellipse(150,y,rx,10,'#527566',.13)
ART={}
def add(name,body,w=300,h=300,outline=None):
 ART[name]={'body':body,'w':w,'h':h,'outline':outline}
 (OUT/(name+'.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{DEFS}{body}</svg>\n',encoding='utf-8')

# A rounded russet coat and a cream snout replace the old triangular comb.
add('hedgehog',shadow(263,103)+path('M49 224Q27 194 43 167Q29 143 53 126Q50 99 80 96Q86 69 115 82Q135 57 161 78Q192 64 206 91Q237 90 240 119Q263 134 248 162Q267 199 238 230Q157 264 49 224','url(#rust)')+path('M57 173Q61 112 115 103Q168 80 213 122Q157 105 112 149Q86 185 57 173','#c7a181')+ellipse(162,215,82,36,'url(#cream)')+ellipse(224,184,56,52,'url(#cream)')+ellipse(189,146,15,19,'#edcda2')+ellipse(190,146,7,10,'#d9959a')+ellipse(214,177,7,10,'#293d39')+ellipse(212,174,2.6,3,'#fffdf4')+ellipse(278,197,10,9,'#674d42')+ellipse(240,204,10,5,'#e6a89b',.65)+path('M242 216q13 6 20-2','none','#986e5b')+ellipse(124,252,25,12,'#e3b888')+ellipse(235,250,24,12,'#e3b888')+''.join(path(f'M{x} {y}q-6 12 1 20','none','#d6b397',2) for x,y in [(71,138),(98,112),(133,103),(170,108),(73,186)]),outline=[[.16,.74],[.12,.6],[.14,.47],[.2,.38],[.3,.29],[.43,.24],[.55,.26],[.69,.31],[.79,.41],[.82,.5],[.91,.6],[.95,.66],[.88,.76],[.8,.86],[.68,.89],[.48,.88],[.3,.86],[.16,.74]])
add('frog',shadow(268,99)+ellipse(150,213,91,49,'url(#leaf)')+ellipse(80,251,39,18,'#80b184')+ellipse(220,251,39,18,'#80b184')+ellipse(150,168,99,67,'url(#leaf)')+ellipse(99,112,32,37,'#b2d398')+ellipse(201,112,32,37,'#b2d398')+ellipse(99,110,22,27,'#fff9e9')+ellipse(201,110,22,27,'#fff9e9')+ellipse(103,111,10,15,'#293d39')+ellipse(197,111,10,15,'#293d39')+ellipse(100,106,4,5,'#fffdf4')+ellipse(194,106,4,5,'#fffdf4')+ellipse(81,174,17,8,'#e3a79c',.65)+ellipse(219,174,17,8,'#e3a79c',.65)+path('M110 179q40 40 80 0','none','#6a8863',4)+ellipse(150,230,40,17,'#d3e3b5'),outline=[[.16,.8],[.18,.58],[.22,.47],[.23,.34],[.3,.26],[.39,.27],[.44,.34],[.56,.34],[.61,.27],[.7,.26],[.77,.34],[.78,.47],[.82,.58],[.84,.8],[.74,.89],[.5,.9],[.26,.89],[.16,.8]])
add('bird',shadow(264,83)+path('M76 190Q30 190 43 149L96 166','url(#blue)')+ellipse(143,189,86,64,'url(#blue)')+ellipse(192,128,48,51,'url(#gold)')+path('M230 133q34 4 29 17l-31 8','url(#gold)')+path('M99 176Q127 144 157 172Q146 218 106 218Q86 202 99 176','#8bb7cb')+ellipse(194,119,7,10,'#293d39')+ellipse(192,116,2.6,3,'#fffdf4')+ellipse(217,143,10,5,'#e8a18f',.6)+path('M129 247v15m40-16v16','none','#bd9b69',5)+path('M172 83q-9-20 4-25m10 25q6-19 17-17','none','#dbb779',5),outline=[[.14,.5],[.3,.55],[.37,.43],[.49,.41],[.5,.3],[.63,.24],[.77,.3],[.81,.43],[.88,.49],[.77,.56],[.75,.7],[.66,.82],[.42,.85],[.24,.77],[.14,.5]])
add('bee',shadow(263,86)+ellipse(121,120,30,55,'#dbedf0',.95)+ellipse(175,118,31,56,'#e5f3ef',.95)+ellipse(145,191,83,62,'url(#gold)')+path('M115 137q-21 58 1 109m35-115q-15 63 1 121m34-110q-4 50 1 96','none','#9e7852',13)+ellipse(210,155,42,43,'url(#gold)')+ellipse(224,146,7,10,'#293d39')+ellipse(222,143,2.5,3,'#fffdf4')+ellipse(237,167,10,5,'#e8a18f',.6)+path('M210 112q-16-25-9-37m23 39q10-22 25-24','none','#9e7852',4)+ellipse(201,74,6,6,'#9e7852')+ellipse(251,89,6,6,'#9e7852'),outline=[[.2,.63],[.25,.5],[.3,.44],[.3,.24],[.4,.2],[.5,.31],[.55,.2],[.65,.23],[.68,.38],[.8,.4],[.85,.5],[.83,.64],[.7,.79],[.5,.86],[.31,.79],[.2,.63]])
add('squirrel',shadow(276,84)+path('M165 240Q288 243 270 137Q263 76 221 86Q174 96 204 147Q230 177 198 191Q169 183 157 213','url(#fur)')+path('M217 109Q250 103 251 146Q251 180 229 197','none','#f3d5aa',11)+ellipse(134,218,62,54,'url(#fur)')+path('M75 116L77 62Q96 44 117 93L152 85Q176 41 194 63L187 125','url(#fur)')+ellipse(133,137,72,62,'url(#fur)')+ellipse(134,171,45,25,'url(#cream)')+face(133,135,.8)+ellipse(132,163,7,5,'#a56b58')+ellipse(112,260,27,14,'#c88d59')+ellipse(161,260,27,14,'#c88d59')+ellipse(135,224,31,32,'url(#cream)')+ellipse(118,211,15,10,'#d89f68')+ellipse(152,211,15,10,'#d89f68'),outline=[[.25,.86],[.23,.7],[.26,.56],[.2,.42],[.25,.23],[.36,.3],[.51,.28],[.64,.21],[.65,.36],[.72,.3],[.85,.34],[.9,.5],[.85,.71],[.73,.85],[.6,.92],[.4,.93],[.25,.86]])
add('penguin',shadow(273,87)+ellipse(150,188,83,81,'#709ba6')+path('M75 167Q25 183 52 224L84 211m141-44q50 16 23 57l-32-13','#6a929f')+ellipse(150,128,69,71,'#719ba6')+ellipse(150,187,59,71,'url(#cream)')+ellipse(124,124,28,36,'#fff8e6')+ellipse(176,124,28,36,'#fff8e6')+face(150,125,.75)+path('M137 148Q150 138 163 148L151 160Z','url(#gold)')+ellipse(109,266,31,13,'#e2ac69')+ellipse(191,266,31,13,'#e2ac69')+path('M91 179q60 30 118-1','none','#e3a1a6',16)+path('M179 181v44','none','#e3a1a6',13),outline=[[.23,.85],[.15,.73],[.18,.61],[.25,.55],[.24,.38],[.3,.25],[.5,.18],[.7,.25],[.76,.38],[.75,.55],[.82,.61],[.85,.73],[.77,.85],[.64,.93],[.36,.93],[.23,.85]])
add('cloud',ellipse(152,149,119,16,'#5f8c96',.08)+path('M51 137Q20 130 28 99Q34 77 62 77Q67 31 111 36Q132 5 173 22Q206 27 211 65Q247 44 271 75Q303 124 261 137Z','url(#cloud)')+path('M62 126Q144 144 252 126','none','#d3e5e5',5)+face(152,88,.55),300,180,outline=[[.12,.76],[.08,.6],[.12,.47],[.23,.43],[.24,.28],[.37,.2],[.47,.12],[.61,.16],[.7,.37],[.81,.34],[.91,.45],[.94,.63],[.87,.78],[.12,.76]])
add('sun',shadow(276,80)+''.join(path(f'M{150+105*math.cos(n*math.tau/12):.1f} {141+105*math.sin(n*math.tau/12):.1f}L{150+123*math.cos(n*math.tau/12):.1f} {141+123*math.sin(n*math.tau/12):.1f}','none','#e9bc65',11) for n in range(12))+ellipse(150,141,88,88,'url(#gold)')+ellipse(125,98,23,12,'#fff5cf',.65)+face(150,145,1.05))
add('moon',shadow(276,78)+path('M193 35Q73 38 66 146Q68 251 189 255Q244 250 271 210Q174 226 151 151Q125 82 193 35','url(#cream)')+face(110,168,.62)+ellipse(101,94,10,12,'#ddc39b',.45))
for season in ['spring','autumn']:
 canopy='url(#leaf)' if season=='spring' else 'url(#autumn)'
 body=ellipse(150,440,91,10,'#527566',.13)+path('M130 428L132 264L90 220L106 202L148 237L192 188L209 200L168 273L174 428Q153 445 130 428','url(#fur)')
 for x,y,rx,ry in [(83,189,57,69),(191,180,71,73),(147,120,67,86),(75,115,48,60),(222,113,44,54)]:body+=ellipse(x,y,rx,ry,canopy)
 body+=path('M72 141q15-51 57-54m34 36q33-31 55-7','none','#d3dfae' if season=='spring' else '#f1cd95',9)
 if season=='spring':
  for x,y in [(75,128),(120,72),(216,147),(161,190)]:
   body+=''.join(ellipse(x+9*math.cos(n*math.tau/5),y+9*math.sin(n*math.tau/5),7,7,'#f2c1c5') for n in range(5))+ellipse(x,y,4,4,'#f6d888')
 else:
  for x,y in [(81,154),(175,90),(213,182),(126,208)]:body+=path(f'M{x} {y}q-19-25-30 0q16 22 30 0','#c77958')
 add('tree_'+season,body,300,460,outline=[[.44,.94],[.43,.64],[.22,.6],[.09,.46],[.08,.29],[.16,.15],[.3,.12],[.43,.07],[.62,.1],[.7,.16],[.85,.16],[.91,.31],[.88,.48],[.71,.59],[.57,.64],[.58,.94],[.44,.94]])
add('pine',ellipse(150,440,88,10,'#527566',.13)+rect(132,342,36,91,'url(#fur)',9)+path('M145 25Q150 14 155 25L222 142Q235 166 204 166L251 259Q270 285 225 282L278 365Q292 390 248 391H52Q8 390 22 365L75 282Q30 285 49 259L96 166Q65 166 78 142Z','url(#leaf)')+path('M106 142q45 17 90 0m-116 121q70 20 140 0m-170 105q100 20 200 0','none','#eff4df',12)+''.join(ellipse(x,y,8,10,c) for x,y,c in [(132,170,'#e5a2ac'),(173,236,'#f4ce81'),(111,296,'#e5a2ac'),(202,333,'#9ccbd2')]),300,460)
add('flowers',shadow(279,98)+''.join(path(f'M{x} {y+12}Q{x+15} 220 {x} 269','none','#78a480',8)+path(f'M{x} 226q-35-37-43-8q21 25 43 8','#a5c98f')+''.join(ellipse(x+23*math.cos(n*math.tau/5),y+23*math.sin(n*math.tau/5),21,23,color) for n in range(5))+ellipse(x,y,22,22,'url(#gold)')+face(x,y,0.35) for x,y,color in [(66,145,'#eeb9c6'),(153,89,'#f2c891'),(237,160,'#d1b7dc')]))
add('butterfly',shadow(278,76)+path('M145 140Q62 47 36 111Q20 166 98 178Q39 217 88 243Q123 254 147 183','url(#pink)')+path('M155 140Q238 47 264 111Q280 166 202 178Q261 217 212 243Q177 254 153 183','url(#blue)')+ellipse(151,161,14,64,'url(#fur)')+ellipse(151,103,22,22,'url(#gold)')+path('M140 88q-25-36-40-16m62 16q25-36 40-16','none','#a38365',4)+face(151,105,.28)+ellipse(76,133,19,26,'#ffe7ce',.65)+ellipse(224,133,19,26,'#eef7f2',.65))
add('nest',shadow(265,104)+''.join(ellipse(x,158,28,44,'url(#cream)')+face(x,157,.3) for x in [90,150,210])+path('M36 164Q150 203 264 164L246 232Q150 275 54 232Z','url(#fur)')+path('M43 171Q150 224 257 171','none','#bb8c61',14)+''.join(path(f'M{47+i*30} 190l37 43','none','#eac69a',5) for i in range(7))+path('M64 235q94 13 173-7','none','#ac7f59',5))
for name in ['pond','puddle']:
 body=ellipse(150,253,131,15,'#527566',.09)+path('M19 159Q9 97 88 92Q143 37 191 92Q284 67 289 156Q311 222 230 235Q183 271 119 237Q25 255 19 159','url(#blue)')+path('M55 165q-8-32 42-38m54-24q60-10 89 20m-172 87q57 23 121 8','none','#e9f6f0',6)
 if name=='pond':body+=ellipse(98,154,35,19,'#8ab58c')+path('M98 154l33-12-7 29Z','#cae0ad')+ellipse(190,178,27,14,'url(#gold)')+path('M169 179l-21-15 1 29Z','#dfad65')+ellipse(202,176,3,4,'#293d39')
 add(name,body)
add('rainbow',shadow(276,110)+''.join(path(f'M{46+i*20} 230A{104-i*20} {160-i*25} 0 0 1 {254-i*20} 230','none',c,20) for i,c in enumerate(['#df9cae','#e7ba7e','#efd688','#aaca9b','#a2cad8']))+ellipse(43,237,38,27,'url(#cloud)')+ellipse(257,237,38,27,'url(#cloud)'))
add('leaves',shadow(277,88)+''.join(f'<g transform="translate({x} {y}) rotate({angle})">'+path('M0-63Q61-20 8 58Q-55 28-24-20Z',fill)+path('M0-47L2 76M1 0l-22-15m24 37 22-20','none','#a17d54',4)+'</g>' for x,y,angle,fill in [(87,176,-30,'#e8b66e'),(190,151,24,'url(#autumn)'),(149,217,2,'#df9272')]))
add('mushrooms',shadow(279,106)+''.join(rect(x-19,y,38,93,'url(#cream)',17)+path(f'M{x-65} {y+7}Q{x-70} {y-66} {x} {y-73}Q{x+70} {y-66} {x+65} {y+7}Q{x} {y+26} {x-65} {y+7}','url(#pink)')+''.join(ellipse(x+dx,y+dy,10,8,'#fff4df') for dx,dy in [(-26,-30),(9,-48),(34,-15)])+face(x,y+42,.4) for x,y in [(87,170),(214,142)]))
add('pumpkin',shadow(276,106)+path('M142 84q-17-43 10-49q25-2 14 46','url(#leaf)')+path('M167 73q55-26 61 12q-1 28-25 9','none','#8cab78',6)+''.join(ellipse(x,177,52,89,'url(#autumn)' if x!=150 else 'url(#gold)') for x in [93,207,150])+face(150,170,1.05))
add('basket',shadow(276,108)+path('M70 155Q57 25 151 29Q241 28 229 155','none','#bb8b61',15)+''.join(ellipse(x,y,35,36,c)+path(f'M{x} {y-28}l4-17','none','#8c9b67',5) for x,y,c in [(91,139,'#d98778'),(150,121,'#e9c181'),(212,139,'#d98778')])+path('M38 154Q150 179 262 154L238 247Q150 286 62 247Z','url(#fur)')+path('M45 164q105 31 210 0','none','#d3a577',16)+''.join(path(f'M{72+i*32} 181l9 68','none','#e6c29a',6) for i in range(6))+path('M58 205h184m-176 28h168','none','#ae815a',5))
add('kite',shadow(280,72)+path('M150 26Q155 24 160 32L242 127Q247 135 240 143L158 221Q150 227 143 220L59 141Q53 134 59 127Z','url(#pink)')+path('M150 30v188M61 135h180','none','#fff0d6',5)+path('M151 223q-40 13-4 32q32 20 3 36','none','#b69879',4)+path('M122 246l25 8-20 12m44 9-19 6 20 10','none','#b5ccac',9)+face(151,133,.7))
add('boots',shadow(278,107)+''.join(path(f'M{x-38} 60Q{x} 49 {x+37} 60L{x+32} 184Q{x+86} 188 {x+82} 236Q{x+79} 257 {x+40} 258H{x-34}Q{x-49} 252 {x-44} 231Z','url(#gold)')+path(f'M{x-37} 74h66m-62 163h111','none','#e0ae63',10)+path(f'M{x-18} 100l-5 79','none','#fff0c4',10) for x in [66,196]))
add('cottage',ellipse(150,357,108,12,'#527566',.13)+rect(47,132,206,209,'url(#cream)',19)+path('M24 145Q17 137 28 126L144 24Q150 19 156 24L272 126Q283 137 276 145Q257 157 240 143L150 65L60 143Q43 157 24 145','url(#blue)')+path('M28 130L150 25L272 130','none','#eff7f1',14)+rect(130,237,58,104,'#94b4ad',14)+ellipse(173,292,5,5,'#ebcc8b')+''.join(rect(x,190,48,53,'url(#blue)',9)+path(f'M{x+24} 192v49m-22-25h44','none','#fff5dd',5) for x in [66,199])+path('M55 319h65m79 0h47','none','#d7b68b',4),300,380)
add('snowman',shadow(278,88)+ellipse(150,215,81,58,'url(#cloud)')+ellipse(150,134,61,57,'url(#cloud)')+path('M76 94Q150 109 224 94','none','#7f9fa9',19)+rect(102,37,96,64,'#7f9fa9',14)+path('M109 83h82','none','#e4c6ad',10)+face(150,132,.9)+path('M148 148l35 9-35 7Z','url(#gold)')+path('M98 177q55 22 107-3','none','#e9afb6',16)+path('M184 180l5 43','none','#e9afb6',13)+''.join(ellipse(150,y,5,6,'#8eabb0') for y in [208,233])+path('M75 201l-35-26m185 26 35-26','none','#af957b',7))
add('sled',shadow(269,114)+path('M30 242H233Q280 241 274 200','none','#8fb6c5',14)+path('M70 238v-63m148 63v-63','none','#b48a67',12)+rect(39,145,217,43,'url(#fur)',15)+path('M55 156h183m-174 19h174','none','#eccb9f',5)+path('M250 152q4-93 38-76','none','#bea180',5))
add('gift',shadow(276,101)+rect(52,109,196,151,'url(#pink)',17)+rect(42,91,216,42,'#e8b0bc',12)+rect(136,94,28,167,'url(#gold)',8)+path('M150 96Q71 98 91 55Q115 16 150 96Q185 16 209 55Q229 98 150 96','none','#edcd88',15)+path('M78 146v88','none','#f7d5d9',8))
add('lantern',shadow(277,92)+path('M112 68Q106 11 151 20Q193 16 189 68','none','#839ea4',10)+rect(81,93,138,152,'url(#gold)',23)+rect(68,72,164,38,'#8facb0',16)+rect(68,230,164,35,'#8facb0',13)+path('M96 114v109m109-109v109','none','#e8f0dd',8)+ellipse(151,173,25,39,'#fff2c7',.8))
points=[(150+116*math.cos(-math.pi/2+n*math.tau/10)*(1 if n%2==0 else .46),142+116*math.sin(-math.pi/2+n*math.tau/10)*(1 if n%2==0 else .46)) for n in range(10)]
add('star',shadow(278,87)+path('M'+'L'.join(f'{x:.1f} {y:.1f}' for x,y in points)+'Z','url(#gold)','#edca7c',6)+face(150,147,.9)+path('M125 72l14-10','none','#fff0bf',8))
add('snowflake',shadow(278,86)+''.join(f'<g transform="translate(150 143) rotate({n*60})">'+path('M0 0V-106M0-62L-29-84M0-62L29-84M0-31L-22-47M0-31L22-47','none','#a9cbdc',10)+ellipse(0,-108,8,8,'#d9ecf0')+'</g>' for n in range(6))+ellipse(150,143,20,20,'#e5f0ee'))
night_cottage=ART['cottage']['body']
for x in [66,199]:night_cottage=night_cottage.replace(rect(x,190,48,53,'url(#blue)',9),rect(x,190,48,53,'url(#gold)',9))
add('cottage_night',night_cottage,300,380)
add('lantern_idle',ART['lantern']['body'].replace(rect(81,93,138,152,'url(#gold)',23),rect(81,93,138,152,'url(#blue)',23)).replace(ellipse(151,173,25,39,'#fff2c7',.8),''))
# House parts remain separate so the trace order, door, lights and smoke work.
add('walls',rect(9,7,282,286,'url(#cream)',15)+path('M17 254h268M17 272h268','none','#dfbc92',4)+''.join(path(f'M{x} 22v211','none','#f5e2c0',3) for x in [48,98,148,198,248]))
add('roof',path('M7 278Q0 270 8 258L141 16Q150 0 159 16L292 258Q300 270 293 278Q150 298 7 278Z','url(#pink)')+path('M24 266L150 35L276 266','none','#f0c5bd',7)+''.join(path(f'M{150-35*n} {85+47*n}q{35*n} 15 {70*n} 0','none','#cb8f8c',4) for n in range(1,5)))
add('chimney',rect(42,15,216,273,'url(#fur)',12)+rect(18,9,264,48,'#d9b197',12)+''.join(path(f'M48 {y}h204m-102 0v39','none','#bd947a',4) for y in [82,160,238]))
for state in ['idle','active']:
 window=rect(12,10,276,278,'#d7b48a',20)+rect(31,28,238,237,'url(#gold)' if state=='active' else 'url(#blue)',13)+path('M150 30v235M32 147h236','none','#fff4dd',13)+rect(2,266,296,29,'#d1a77e',12)
 if state=='idle':window+=path('M50 48l55 60m62-55 63 67','none','#edf7f1',9)
 add('window_'+state,window)
add('door_idle',rect(20,2,260,298,'#dcc09a',24)+rect(38,22,224,278,'#92b8b0',20)+path('M60 47v228','none','#b8d4c2',8)+ellipse(225,166,11,9,'#f0d590'))
add('door_active',rect(20,2,260,298,'#dcc09a',24)+rect(38,22,224,278,'#607b72',20)+path('M40 22L136 55V281L40 300Z','#94b9ae')+ellipse(113,173,8,8,'#efd69b'))

registry=json.loads((R/'data/game_content/design_visual_overrides.json').read_text(encoding='utf-8'))
for story in ['house','spring','autumn','winter']:
 data=json.loads((R/f'data/game_content/living_{story}.json').read_text(encoding='utf-8'))
 for part in data['parts']:
  key=part['id'];name={'left_window':'window_idle','right_window':'window_idle','door':'door_idle','tree':'tree_'+story,'lantern':'lantern_idle'}.get(key,key)
  if key in ['dog','bunny']:
   target='res://assets/objects/animals/'+('dog' if key=='dog' else 'rabbit')+'.svg'
  else:target='res://assets/illustrations/stories/'+name+'.svg'
  if not (R/target.removeprefix('res://')).exists():raise ValueError('Missing story art '+target)
  entry={'texture':target,'source_note':'Project-original companion-style SVG artwork; tools/prepare_story_illustrations.py'}
  if story=='house' and key not in ['sun','cloud','dog','flowers']:entry['fit']='stretch'
  if key=='sun':entry['variants']={'night':'res://assets/illustrations/stories/moon.svg'}
  if key in ['left_window','right_window']:entry['variants']={'active':'res://assets/illustrations/stories/window_active.svg','night':'res://assets/illustrations/stories/window_active.svg'}
  if key=='cottage':entry['variants']={'night':'res://assets/illustrations/stories/cottage_night.svg','active':'res://assets/illustrations/stories/cottage_night.svg'}
  if key=='lantern':entry['variants']={'night':'res://assets/illustrations/stories/lantern.svg','active':'res://assets/illustrations/stories/lantern.svg'}
  if key=='door':entry['variants']={'active':'res://assets/illustrations/stories/door_active.svg'}
  if story!='house' and name in ART and ART[name].get('outline'):
   art=ART[name];bw,bh=part['box'][2:];factor=min(bw/art['w'],bh/art['h']);fw,fh=art['w']*factor,art['h']*factor
   x,y=part['marker'];part['strokes']=[[[round(x-fw/2+a*fw,2),round(y-fh/2+b*fh,2)] for a,b in art['outline']]]
  registry['overrides']['story/'+story+'/'+key]=entry
 (R/f'data/game_content/living_{story}.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(R/'data/game_content/design_visual_overrides.json').write_text(json.dumps(registry,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Story illustrations:',len(ART),'SVGs;',len(registry['overrides']),'story overrides')

if __name__=='__main__':pass
