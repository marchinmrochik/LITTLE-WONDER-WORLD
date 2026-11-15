"""Original vector alphabet cards; finite locale-bound letter and word speech."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8"))
def write(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
# Paths are hand-authored vector illustrations, not glyphs from an emoji font.
art={
"bus":'<rect x="35" y="60" width="230" height="130" rx="25" fill="#eec655"/><path d="M55 80H245V133H55Z" fill="#bde4e5"/><path d="M113 80V133M180 80V133"/><circle cx="85" cy="195" r="22" fill="#657a78"/><circle cx="220" cy="195" r="22" fill="#657a78"/>',
"mushroom":'<path d="M125 130L115 220Q150 238 185 220L175 130" fill="#f7e6c9"/><path d="M30 135Q150 -50 270 135Q150 170 30 135Z" fill="#e58f85"/><g fill="#fff4d8" stroke="none"><circle cx="95" cy="100" r="15"/><circle cx="160" cy="65" r="18"/><circle cx="211" cy="112" r="12"/></g>',
"button":'<circle cx="150" cy="125" r="95" fill="#9dbbd4"/><circle cx="150" cy="125" r="72" fill="#bfd3e2"/><g fill="#64796f"><circle cx="130" cy="105" r="9"/><circle cx="170" cy="105" r="9"/><circle cx="130" cy="145" r="9"/><circle cx="170" cy="145" r="9"/></g>',
"screen":'<rect x="30" y="35" width="240" height="150" rx="14" fill="#82b6c5"/><rect x="45" y="50" width="210" height="117" rx="5" fill="#c9e9e6"/><path d="M130 185V213H100V225H200V213H170V185" fill="#98a9a3"/><path d="M92 120L128 86L163 118L190 97L225 143H70Z" fill="#80b280"/>',
"raccoon":'<path d="M72 70L50 28L115 50M190 50L250 28L230 78" fill="#8d9b99"/><ellipse cx="150" cy="136" rx="105" ry="89" fill="#b5c0ba"/><path d="M47 112Q92 72 150 125Q208 72 253 112L230 160Q188 176 150 142Q111 176 70 160Z" fill="#657978"/><circle cx="101" cy="127" r="11" fill="#fff8ec"/><circle cx="199" cy="127" r="11" fill="#fff8ec"/><ellipse cx="150" cy="177" rx="48" ry="35" fill="#fff8ec"/><path d="M136 165Q150 153 164 165L150 180Z" fill="#496557"/>',
"beetle":'<path d="M90 100L55 75M80 135H40M90 170L55 198M210 100L245 75M220 135H260M210 170L245 198" fill="none" stroke-width="9"/><circle cx="150" cy="65" r="35" fill="#657978"/><ellipse cx="150" cy="145" rx="72" ry="84" fill="#e58981"/><path d="M150 65V229" fill="none"/><g fill="#496557"><circle cx="113" cy="118" r="13"/><circle cx="187" cy="118" r="13"/><circle cx="112" cy="177" r="13"/><circle cx="188" cy="177" r="13"/></g>',
"turkey":'<g fill="#bd926f"><ellipse cx="80" cy="110" rx="30" ry="75" transform="rotate(-35 80 110)"/><ellipse cx="120" cy="85" rx="30" ry="75"/><ellipse cx="180" cy="85" rx="30" ry="75"/><ellipse cx="220" cy="110" rx="30" ry="75" transform="rotate(35 220 110)"/></g><ellipse cx="150" cy="157" rx="65" ry="62" fill="#927055"/><path d="M125 208V235M175 208V235"/><circle cx="150" cy="100" r="32" fill="#a9c7d1"/><path d="M172 100L204 113L173 120" fill="#efc65c"/><path d="M172 118Q192 155 167 150" fill="#d78b85"/><circle cx="153" cy="92" r="6" fill="#496557"/>',
"hedgehog":'<path d="M35 175L20 130L52 132L44 88L82 102L98 50L127 83L160 37L176 80L216 57L216 98L259 93L244 139L275 163L237 202H53Z" fill="#a78b75"/><path d="M125 180Q137 104 203 146L273 190Q230 230 146 219Z" fill="#edc9a7"/><circle cx="270" cy="189" r="10" fill="#496557"/><circle cx="212" cy="174" r="7" fill="#496557"/><ellipse cx="87" cy="215" rx="25" ry="12" fill="#edc9a7"/>',
"yogurt":'<path d="M85 68H215L198 227H102Z" fill="#fff5e2"/><path d="M94 130H207L200 190H100Z" fill="#e9a0b8"/><ellipse cx="150" cy="68" rx="70" ry="18" fill="#b8d6d8"/><path d="M170 52L204 13" stroke="#99b8c1" stroke-width="12"/><path d="M132 151Q150 130 167 151L150 179Z" fill="#d87979"/>',
"tent":'<path d="M30 220L150 30L270 220Z" fill="#edb36c"/><path d="M95 220L150 100L205 220Z" fill="#7eaba5"/><path d="M150 100V220M15 227H285" fill="none"/>',
"fish":'<path d="M215 125L275 65V185Z" fill="#e6b661"/><ellipse cx="137" cy="125" rx="100" ry="75" fill="#8dbfd1"/><path d="M116 53L156 20L184 61M115 198L154 227L183 189" fill="#e6b661"/><circle cx="83" cy="105" r="10" fill="#496557"/><path d="M62 144Q82 160 99 146M150 60Q120 125 150 191" fill="none"/>',
"fountain":'<path d="M54 188H246Q230 228 150 228Q70 228 54 188Z" fill="#9dbacb"/><path d="M130 190V122H170V190" fill="#b5d1dc"/><path d="M67 112H233Q210 148 150 148Q90 148 67 112Z" fill="#9dbacb"/><path d="M150 110V34M150 65Q103 8 67 80M150 65Q197 8 233 80" fill="none" stroke="#7dbdd0" stroke-width="10"/>',
"onion":'<path d="M143 70L122 15M153 70L165 10M161 76L203 28" fill="none" stroke="#80b280" stroke-width="14"/><path d="M149 65Q110 108 76 136Q27 233 150 235Q273 233 224 136Q185 104 149 65Z" fill="#e6c393"/><path d="M145 82Q65 200 128 230M159 85Q225 195 175 230" fill="none" stroke="#bd926f"/>',
"turtle":'<ellipse cx="237" cy="135" rx="40" ry="30" fill="#a9c58c"/><path d="M85 177L65 218H107L127 180M170 177L180 218H218L209 174" fill="#a9c58c"/><path d="M38 166Q35 52 144 50Q245 55 236 166Z" fill="#80b280"/><path d="M80 163L95 100L150 78L204 104L218 163M95 100L141 143L204 104M141 143V165" fill="none"/><circle cx="249" cy="128" r="5" fill="#496557"/>',
"hat":'<path d="M56 170Q55 55 150 48Q245 55 244 170Z" fill="#e9a0b8"/><rect x="45" y="159" width="210" height="48" rx="18" fill="#bfd2df"/><circle cx="150" cy="34" r="25" fill="#bfd2df"/><path d="M100 163Q92 97 119 66M150 160V58M201 163Q207 97 181 65" fill="none"/>',
"brush":'<rect x="48" y="65" width="132" height="80" rx="30" fill="#edb36c"/><rect x="170" y="86" width="105" height="37" rx="18" fill="#edb36c"/><path d="M65 143V183M85 145V183M105 145V183M125 145V183M145 145V183M165 141V180" stroke="#718f98" stroke-width="10"/>',
"top":'<path d="M150 25V65" stroke-width="14"/><path d="M150 58L55 138L150 220L245 138Z" fill="#e9a0b8"/><path d="M55 138H245M88 110H213M90 169H210" fill="none" stroke="#efcc66" stroke-width="16"/><path d="M150 218V235" stroke-width="9"/>',
"goat":'<path d="M95 75Q50 0 78 10Q105 15 117 68M183 68Q196 15 222 10Q250 0 205 75" fill="#d6c39f"/><path d="M95 85L30 72Q24 120 92 132M205 85L270 72Q276 120 208 132" fill="#e0cdb1"/><path d="M90 70Q150 40 210 70L200 184Q150 230 100 184Z" fill="#fff0d3"/><circle cx="117" cy="126" r="8" fill="#496557"/><circle cx="183" cy="126" r="8" fill="#496557"/><path d="M140 172L150 185L160 172M130 205L150 242L170 205" fill="#d6c39f"/>',
"house":'<rect x="65" y="105" width="170" height="125" rx="8" fill="#f0c69d"/><path d="M30 112L150 20L270 112Z" fill="#da9290"/><rect x="130" y="155" width="45" height="75" fill="#92b4c8"/><rect x="85" y="135" width="30" height="36" fill="#c0e2e5"/>',
"icecream":'<path d="M92 115H208L150 240Z" fill="#deb981"/><path d="M111 149L181 185M125 179L169 204M189 148L119 186" fill="none"/><circle cx="150" cy="86" r="61" fill="#eaa6b9"/><path d="M99 63Q151 -7 205 62" fill="#f5dfb4"/>',
"jelly":'<path d="M88 62Q150 36 212 62L248 197Q150 240 52 197Z" fill="#bf91c2"/><ellipse cx="150" cy="62" rx="62" ry="20" fill="#dcb0d7"/><path d="M91 102L77 181M211 102L223 181" stroke="#eacde5" stroke-width="9"/>',
"kite":'<path d="M150 20L235 100L150 190L65 100Z" fill="#e9a0b8"/><path d="M150 20V190M65 100H235" fill="none"/><path d="M150 190Q190 219 141 241" fill="none"/><path d="M157 210L132 203V226Z" fill="#efc65c"/>',
"moon":'<path d="M210 30Q20 -8 36 153Q60 270 222 212Q84 202 120 87Q141 44 210 30Z" fill="#efce67"/><circle cx="80" cy="118" r="10" fill="#e4bc50" stroke="none"/>',
"nest":'<path d="M32 141H268Q256 231 150 230Q44 231 32 141Z" fill="#b48b61"/><g fill="#e1ede7"><ellipse cx="110" cy="122" rx="30" ry="44"/><ellipse cx="180" cy="119" rx="30" ry="44"/></g><path d="M35 149Q150 198 265 149M52 178Q150 218 248 178M85 218L66 162M215 218L235 162" fill="none"/>',
"queen":'<path d="M76 136Q64 65 150 60Q235 65 224 136V222H76Z" fill="#a98460"/><ellipse cx="150" cy="140" rx="65" ry="77" fill="#edc9a7"/><path d="M88 75L73 22L123 50L150 12L180 50L227 22L213 75Z" fill="#efce67"/><circle cx="126" cy="132" r="6" fill="#496557"/><circle cx="174" cy="132" r="6" fill="#496557"/><path d="M132 167Q150 182 168 167" fill="none"/>',
"sun":'<g stroke="#e8bb56" stroke-width="12"><path d="M150 10V40M150 210V240M35 125H5M265 125H295M48 23L70 47M231 202L254 227M48 227L70 204M231 47L254 23"/></g><circle cx="150" cy="125" r="75" fill="#efce67"/><circle cx="125" cy="115" r="6" fill="#496557"/><circle cx="175" cy="115" r="6" fill="#496557"/><path d="M127 146Q150 163 173 146" fill="none"/>',
"umbrella":'<path d="M150 111V213Q149 246 118 225" fill="none" stroke-width="10"/><path d="M25 125Q150 -45 275 125Q235 94 192 125Q150 91 108 125Q66 94 25 125Z" fill="#9dbbd4"/><path d="M150 18Q98 64 108 125M150 18Q205 65 192 125" fill="none"/>',
"violin":'<path d="M134 20H165V95Q218 75 218 124Q180 131 210 162Q237 217 150 235Q63 217 90 162Q120 131 82 124Q82 75 134 95Z" fill="#bd926f"/><path d="M146 20V210M155 20V210M122 182H179" fill="none"/><path d="M243 20L260 229" stroke="#8f765c" stroke-width="8"/>',
"whale":'<path d="M30 128Q45 56 150 79Q205 82 232 151L276 116L268 183L227 203Q49 258 30 128Z" fill="#8dbfd1"/><path d="M38 154Q80 205 213 192" fill="none"/><circle cx="80" cy="121" r="7" fill="#496557"/><path d="M104 73V27M103 45Q80 8 64 35M104 45Q130 9 143 33" fill="none" stroke="#8dbfd1" stroke-width="9"/>',
"yoyo":'<path d="M137 21Q150 70 105 93" fill="none"/><ellipse cx="150" cy="157" rx="90" ry="68" fill="#e9a0b8"/><ellipse cx="150" cy="151" rx="66" ry="49" fill="#f3bdd0"/><circle cx="150" cy="151" r="18" fill="#efce67"/>',
"zebra":'<path d="M95 65L75 17L115 28L134 66M172 61L205 19L223 26L207 82" fill="#fff8ec"/><path d="M105 53Q194 42 213 112L222 203Q165 254 97 202L78 120Z" fill="#fff8ec"/><path d="M120 62L136 116L148 60M173 61L167 113L192 76M91 117L119 135L87 142M210 128L181 145L214 155" fill="#657978"/><ellipse cx="151" cy="199" rx="66" ry="33" fill="#b5c0ba"/><circle cx="117" cy="149" r="7" fill="#496557"/><circle cx="182" cy="149" r="7" fill="#496557"/>'
}
out=ROOT/"assets/objects/alphabet";out.mkdir(parents=True,exist_ok=True)
for name,paths in art.items():(out/(name+".svg")).write_text('<svg xmlns="http://www.w3.org/2000/svg" width="600" height="500" viewBox="0 0 300 250"><g stroke="#496557" stroke-width="4" stroke-linecap="round" stroke-linejoin="round">'+paths+'</g></svg>',encoding="utf-8")
def path(name):
 for folder in ["alphabet","animals","food","world"]:
  p=f"assets/objects/{folder}/{name}.svg"
  if (ROOT/p).exists():return "res://"+p
 if name=="xylophone":return "res://assets/ui/xylophone.svg"
 raise ValueError(name)
words={
"en":[("Apple","apple"),("Bear","bear"),("Cat","cat"),("Dog","dog"),("Elephant","elephant"),("Flower","flower"),("Goat","goat"),("House","house"),("Ice cream","icecream"),("Jelly","jelly"),("Kite","kite"),("Lion","lion"),("Moon","moon"),("Nest","nest"),("Orange","orange"),("Pig","pig"),("Queen","queen"),("Rabbit","rabbit"),("Sun","sun"),("Tree","tree"),("Umbrella","umbrella"),("Violin","violin"),("Whale","whale"),("Xylophone","xylophone"),("Yo-yo","yoyo"),("Zebra","zebra")],
"uk":[("Автобус","bus"),("Банан","banana"),("Ведмідь","bear"),("Гриб","mushroom"),("Ґудзик","button"),("Дерево","tree"),("Екран","screen"),("Єнот","raccoon"),("Жук","beetle"),("Заєць","rabbit"),("Сир","cheese"),("Індик","turkey"),("Їжак","hedgehog"),("Йогурт","yogurt"),("Кіт","cat"),("Лев","lion"),("Морква","carrot"),("Намет","tent"),("Огірок","cucumber"),("Полуниця","strawberry"),("Риба","fish"),("Слон","elephant"),("Томат","tomato"),("Усмішка","sun"),("Фонтан","fountain"),("Хліб","bread"),("Цибуля","onion"),("Черепаха","turtle"),("Шапка","hat"),("Щітка","brush"),("Кінь","horse"),("Юла","top"),("Яблуко","apple")]
}
# A face-only smile is distinct from a sun illustration.
(out/"smile.svg").write_text('<svg xmlns="http://www.w3.org/2000/svg" width="600" height="500" viewBox="0 0 300 250"><circle cx="150" cy="125" r="100" fill="#edc9a7" stroke="#496557" stroke-width="4"/><g fill="#496557"><circle cx="112" cy="103" r="9"/><circle cx="188" cy="103" r="9"/></g><path d="M92 149Q150 218 208 149Z" fill="#fff8ec" stroke="#496557" stroke-width="5"/></svg>',encoding="utf-8")
words['uk'][23]=('Усмішка','smile')
data=read('data/game_content/letters.json');en=read('data/localization/en.json');uk=read('data/localization/uk.json');manifest=read('data/game_content/foundation.json');jobs=read('data/game_content/voice_jobs.json')
for loc in jobs:jobs[loc]=[j for j in jobs[loc] if not j['key'].startswith('ALPH_')]
names_en=['Ay','Bee','See','Dee','Ee','Ef','Jee','Aitch','Eye','Jay','Kay','El','Em','En','Oh','Pee','Cue','Ar','Ess','Tee','You','Vee','Double you','Ex','Why','Zed']
names_uk=['А','Бе','Ве','Ге','Ґе','Де','Е','Є','Же','Зе','И','І','Ї','Йот','Ка','Ел','Ем','Ен','О','Пе','Ер','Ес','Те','У','Еф','Ха','Це','Че','Ша','Ща',"М’який знак",'Ю','Я']
def voice(key,text,loc):
 file=f'assets/audio/voice/{loc}/{key.lower()}.wav';manifest['voice'][key]={'en':'res://'+file,'uk':'res://'+file};manifest.setdefault('study_locales',{})[key]=loc
 jobs[loc].append({'key':key,'text':text,'file':file});en[key]=text;uk[key]=text
for loc,entries in data['alphabets'].items():
 for i,e in enumerate(entries):
  name=(names_en if loc=='en' else names_uk)[i]
  voice(e['word_key'],(e['upper'] if loc=='en' else name.lower())+'.',loc)
  word,art_id=words[loc][i];highlight=word.lower().index(e['lower'])
  e.update({'name':name,'example':word,'illustration':path(art_id),'example_key':f'ALPH_WORD_{loc.upper()}_{i:02d}','highlight_index':highlight,'initial':highlight==0})
  assert word[highlight].lower()==e['lower']
  assert highlight==0 or loc=='uk' and e['upper'] in ['И','Ь']
  voice(e['example_key'],word+'.',loc)
for k,a,b in [('ALPH_LETTERS','Letters','Літери'),('ALPH_PICTURES','Letter + picture','Літера з малюнком'),('ALPH_SWIPE','Swipe to see the next picture.','Гортай, щоб побачити наступний малюнок.'),('ALPH_INSIDE','Find the highlighted letter in the word.','Знайди виділену літеру в слові.'),('ALPH_POSITION','{current} / {total}','{current} / {total}')]:en[k]=a;uk[k]=b
write('data/game_content/letters.json',data);write('data/localization/en.json',en);write('data/localization/uk.json',uk);write('data/game_content/foundation.json',manifest);write('data/game_content/voice_jobs.json',jobs)
print('Alphabet cards:59 checked letter/word/image mappings; isolated spoken names, no sentence prefix.')
