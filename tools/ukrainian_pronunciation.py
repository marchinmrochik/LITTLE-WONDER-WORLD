"""Finite Ukrainian pronunciation lexicon for authored game phrases.
Stress is explicit; UI spelling remains unchanged. Future polysyllabic words require review.
"""
import json,re,sys,wave
from pathlib import Path
import letter_aligned as aligned
R=Path(__file__).resolve().parents[1]
VOWELS='аеєиіїоуюя'
ACCENTED='''
змі́я кота́ ку́льки не́ї тома́т щоку́

єно́т інди́к їжа́к авто́бус апельси́н бана́н брова́ буди́нок веди́ ведмі́дь весе́лка воло́сся ву́хо вівця́ відкри́й відпочи́ньмо ві́сім голова́ гру́ша де́в'ять де́рево де́сять диноза́вр доло́ня дя́кую екра́н завда́ння за́єць збері́мо зеле́ний знайди́ знайді́мо зі́рка йо́гурт каву́н ка́чка квадра́т кві́тка ко́ло колі́но кори́чневий коро́ва ко́рінь кро́лик ку́рка ли́сиця листо́к ло́пни лі́коть малю́й маши́на мете́лик молоде́ць молоко́ мо́рква намалю́й намалю́ймо наме́т насіни́на натиска́й нати́сни нога́ ну́ль ня́м обери́ огіро́к оди́н о́ко па́лець перетягни́ плече́ покажи́ поклади́ полуни́ця помара́нчевий помідо́р пораху́ймо пошука́ймо приві́т прямоку́тник підборі́ддя ри́ба ри́бка роже́вий рука́ сви́нка се́рце си́ній скі́льки соба́ка сосна́ спро́буймо ступня́ твою́ ти́ трава́ трику́тник ту́луб усмі́шка усі́ фо́ксі фонта́н фіоле́товий цибу́ля черво́ний черепа́ха чоти́ри чудо́ва чудо́во ша́пка ши́я щока́ щі́тка юла́ я́блуко яки́й
апельси́н бана́н бджі́лку брову́ бі́лочку ведме́дя весе́лку ви́йшло воло́сся ву́хо вівцю́ віко́нце ві́сім гарбу́з гнізде́чко го́лову гото́вий гото́ві гра́йся грибо́чки гру́шу две́рі дво́рик дві́ де́в'ять де́рево де́сять доло́ню дослі́джуй до́щик дру́ге жа́бку живі́т жо́втий заве́ршено зага́вкає за́йчика збере́жено зеле́ний зеле́ною змі́нювати знайшо́в зі́рки зі́рку зіро́к зі́рочку каву́н калю́жку карти́нка карти́нки карти́нку ка́ртки ка́чку квадра́т кві́ти кві́тку кві́точку ко́ло кольори́ колі́но ко́лір ко́нтур коня́ кори́чневий коро́ву ко́рінь ко́шик кра́пкою кра́пку крапочо́к кро́лика ку́рку ла́ска ле́ва листо́к листо́чки лі́коть ліхта́рик мале́ньку малю́й малю́нки малю́нок мені́ мете́лика мете́лики молоко́ моркви́н моркви́ни моркви́ну мо́ркву мі́сце мі́сці мі́сяць м'яки́й насіни́ну но́гу ньо́го обла́сті огіро́к одне́ одну́ ожи́в ожива́є о́ко па́лець па́льчиком па́ра па́ри пе́сика плече́ побіжи́ть пові́тряного подару́нок полуни́ць полуни́цю полуни́ці помара́нчевий помідо́р порахува́в прилеті́ли прямоку́тник пта́шку підборі́ддя підхо́дить пі́кнік пінгві́на пішо́в ра́зом раху́єш роже́вий розмальо́вку ру́ку са́нчата сви́нку се́рце си́ній скла́в слона́ сніговика́ сніжи́нку соба́ку со́нечко сосну́ ставо́чок ступню́ сті́ни ся́ючу те́бе твари́нки твари́нок торкни́сь траву́ трику́тник трубу́ ту́луб уздо́вж усі́ фігу́р фігу́ри фіоле́товий хати́нку хмари́нку части́нка черво́ний чобі́тки чоти́ри чудо́вий чудо́во чудо́ві ши́ю що́ку я́блук я́блука я́блуко яли́нку і́нше і́нший їжа́чка ї́жу ґу́дзик м'я́чика
'''
LEXICON={}
for marked in ACCENTED.split():
 plain=marked.replace('\u0301','').lower().replace('’',"'")
 before=marked.split('\u0301')[0];index=sum(c in VOWELS for c in before.lower())-1
 LEXICON[plain]=index
TOKEN=re.compile("[а-яіїєґА-ЯІЇЄҐ’']+|[^а-яіїєґА-ЯІЇЄҐ’']+")
IPA_VOWELS='aeiouɑɐɛɪɔʊɨɜə'
CACHE={}
def word_phonemes(word):
 plain=word.lower().replace('’',"'")
 if plain in CACHE:return CACHE[plain]
 phones=aligned.ipa(plain,'uk').replace('ˈ','').replace('ˌ','')
 vowels=[i for i,c in enumerate(phones) if c in IPA_VOWELS]
 count=sum(c in VOWELS for c in plain)
 if count>1 and plain not in LEXICON:raise ValueError('Ukrainian word needs stress review: '+plain)
 if count and vowels:
  index=LEXICON.get(plain,0)
  if index>=len(vowels):raise ValueError('Vowel/stress alignment: '+plain+' '+phones)
  at=vowels[index];phones=phones[:at]+'ˈ'+phones[at:]
 CACHE[plain]=phones;return phones

def phonemes(text):
 result=[]
 for token in TOKEN.findall(text):
  result.append(word_phonemes(token) if re.match('[а-яіїєґА-ЯІЇЄҐ]',token) else token.replace('’',"'"))
 return ''.join(result)

def render(entry,path):
 session,config,_=aligned.model('uk');source=phonemes(entry['text']);ids=[1,0]
 for symbol in source:
  if symbol not in config['phoneme_id_map']:raise ValueError('Unknown phoneme '+repr(symbol)+' in '+entry['key'])
  ids.extend(config['phoneme_id_map'][symbol]);ids.append(0)
 ids.append(2)
 feeds={'input':aligned.np.asarray([ids],dtype=aligned.np.int64),'input_lengths':aligned.np.asarray([len(ids)],dtype=aligned.np.int64),'scales':aligned.np.asarray([.35,1.12,.4],dtype=aligned.np.float32),'letter_duration_mask':aligned.np.ones((1,1,len(ids)),dtype=aligned.np.float32)}
 audio=session.run([session.get_outputs()[0].name],feeds)[0].reshape(-1)
 pcm=aligned.np.clip(audio*32767/max(.01,float(aligned.np.max(aligned.np.abs(audio)))),-32767,32767).astype('<i2')
 path.parent.mkdir(parents=True,exist_ok=True)
 with wave.open(str(path),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(config['audio']['sample_rate']);f.writeframes(pcm.tobytes())
 return source

if __name__=='__main__':
 jobs=json.loads((R/'data/game_content/voice_jobs.json').read_text(encoding='utf-8'))['uk'];missing=[]
 for entry in jobs:
  if aligned.is_letter(entry['key']):continue
  try:phonemes(entry['text'])
  except ValueError as e:missing.append(str(e))
 print('\n'.join(sorted(set(missing))));print('Audited',len(jobs),'jobs;',len(set(missing)),'unreviewed words')
 raise SystemExit(bool(missing))
