"""Refine line art without touching speech jobs; retain revision1 for saved work."""
from pathlib import Path
import json,math,re
ROOT=Path(__file__).resolve().parents[1]

def main():
 path=ROOT/'data/game_content/coloring.json';data=json.loads(path.read_text(encoding='utf-8'))
 legacy=ROOT/'data/game_content/coloring_legacy.json'
 if not legacy.exists():legacy.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 for page in data['pages']:
  if page['id']=='fox':
   page['hidden']=True
   for region in page['regions']:
    if region['id'] not in ['left_cheek','right_cheek']:continue
    x=435 if region['id']=='left_cheek' else 565;y=282
    region['polygon']=[[round(x+35*math.cos(i*math.pi/32),2),round(y+20*math.sin(i*math.pi/32),2)] for i in range(64)]
    region['tap']=[x,y]
    points=' '.join(f'{a},{b}' for a,b in region['polygon'])
    pattern=r'<polygon points="[^"]+" fill="\{\{'+region['id']+r'\}\}"[^>]*/>'
    page['template']=re.sub(pattern,'<polygon points="'+points+'" fill="{{'+region['id']+'}}" stroke="#354940" stroke-width="8" stroke-linejoin="round"/>',page['template'])
  page['template']=page['template'].replace('stroke-width="6"','stroke-width="8"')
  # Small eye highlights preserve the existing locked eye regions.
  if not page.get('art_revision')==2:
   def sparkle(match):
    x,y,r=map(float,match.groups())
    return match.group(0)+(f'<circle cx="{x-r*.27}" cy="{y-r*.28}" r="{r*.25}" fill="#ffffff"/>' if r>=8 else '')
   page['template']=re.sub(r'<circle cx="([\d.]+)" cy="([\d.]+)" r="([\d.]+)" fill="#354940"/>',sparkle,page['template'])
  points=[point for region in page['regions'] for point in region['polygon']]
  left=max(0,min(p[0] for p in points)-38);top=max(0,min(p[1] for p in points)-38)
  right=min(1024,max(p[0] for p in points)+38);bottom=min(640,max(p[1] for p in points)+38)
  page['bounds']=[left,top,right-left,bottom-top];page['art_revision']=2;page['outline_width']=8
  preview=page['template']
  for region in page['regions']:preview=preview.replace('{{'+region['id']+'}}','#ffffff')
  (ROOT/page['preview'].removeprefix('res://')).write_text(preview+'\n',encoding='utf-8')
 path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print('Refined10 coloring pages; original revision retained for existing drawings.')

if __name__=='__main__':main()
