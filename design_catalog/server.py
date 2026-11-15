"""Loopback-only design catalog server. No dependencies, accounts or external requests."""
import argparse,os,json,mimetypes,secrets,subprocess,sys,threading,urllib.parse
from http.server import BaseHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path
from catalog import Catalog,safe
import voice_review
ROOT=Path(__file__).resolve().parents[1]
class Server(ThreadingHTTPServer):
 def __init__(self,address,root=ROOT):
  self.catalog=Catalog(root);self.token=secrets.token_urlsafe(32);self.job={'running':False};super().__init__(address,Handler)
class Handler(BaseHTTPRequestHandler):
 server_version='WonderCatalog/1.0'
 def log_message(self,*args):pass
 def send_bytes(self,status,data,mime='application/json',asset=False):
  self.send_response(status);self.send_header('Content-Type',mime);self.send_header('Content-Length',str(len(data)));self.send_header('X-Content-Type-Options','nosniff');self.send_header('Cache-Control','no-store');self.send_header('Referrer-Policy','no-referrer')
  self.send_header('Content-Security-Policy',"default-src 'self'; img-src 'self' data: blob:; media-src 'self' blob:; font-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self'; object-src 'none'; frame-ancestors 'none'; base-uri 'none'")
  self.end_headers();self.wfile.write(data)
 def json(self,data,status=200):self.send_bytes(status,json.dumps(data,ensure_ascii=False).encode(),'application/json; charset=utf-8')
 def host_ok(self):return self.headers.get('Host') in [f'127.0.0.1:{self.server.server_port}',f'localhost:{self.server.server_port}']
 def do_GET(self):
  try:
   if not self.host_ok():return self.json({'error':'Недопустимый Host'},403)
   parsed=urllib.parse.urlsplit(self.path);q=urllib.parse.parse_qs(parsed.query);path=parsed.path;c=self.server.catalog
   if path=='/api/catalog':return self.json({**c.refresh(),'token':self.server.token,'history':c.history(),'drafts':[__import__('catalog').read_json(p) for p in (c.root/'.local/design-catalog/drafts').glob('*/draft.json') if not __import__('catalog').read_json(p).get('applied')],'job':self.server.job})
   if path=='/api/draft':return self.json(c.load_draft(q.get('id',[''])[0]))
   if path=='/api/job':return self.json(self.server.job)
   if path=='/api/source':return self.json({'text':c.source(q.get('path',[''])[0])})
   if path=='/api/history':return self.json(c.history())
   if path=='/api/voice-review':return self.json(voice_review.snapshot(c.root))
   if path=='/voice-candidate':
    file=voice_review.candidate(c.root,q.get('variant',[''])[0],q.get('locale',[''])[0],q.get('key',[''])[0]);return self.send_bytes(200,file.read_bytes(),'audio/wav',True)
   if path=='/media':
    e=c.entry(q.get('id',[''])[0])
    if e['type'] not in ['image','audio','font']:raise ValueError('У элемента нет медиафайла')
    file=safe(c.root,e['path']);return self.send_bytes(200,file.read_bytes(),mimetypes.guess_type(file.name)[0] or 'application/octet-stream',True)
   if path=='/preview':
    name=q.get('name',[''])[0]
    if '/' in name or '\\' in name or not name.endswith('.png'):raise ValueError('Некорректное превью')
    file=safe(c.root,'.local/design-catalog/previews/'+name)
    if not file.is_file():return self.json({'error':'Превью ещё не сформировано'},404)
    return self.send_bytes(200,file.read_bytes(),'image/png',True)
   if path=='/draft-media':
    d=c.load_draft(q.get('id',[''])[0]);file=c.root/'.local/design-catalog/drafts'/d['id']/d['file'];return self.send_bytes(200,file.read_bytes(),'image/png' if d['extension']=='.png' else 'image/svg+xml',True)
   if path in ['/voice-review','/voice_review.js','/voice_review.css']:
    file=Path(__file__).parent/({'/voice-review':'voice_review.html'}.get(path,path[1:]));return self.send_bytes(200,file.read_bytes(),{'/voice-review':'text/html; charset=utf-8','/voice_review.js':'text/javascript; charset=utf-8','/voice_review.css':'text/css; charset=utf-8'}[path])
   if path in ['/','/app.js','/style.css']:
    file=Path(__file__).parent/({'/':'index.html'}.get(path,path[1:]));return self.send_bytes(200,file.read_bytes(),{'/':'text/html; charset=utf-8','/app.js':'text/javascript; charset=utf-8','/style.css':'text/css; charset=utf-8'}[path])
   return self.json({'error':'Не найдено'},404)
  except (ValueError,KeyError,FileNotFoundError) as e:self.json({'error':str(e)},400)
  except Exception:self.json({'error':'Не удалось прочитать элемент каталога. Проверьте журнал сервера.'},500)
 def do_POST(self):
  try:
   origin=self.headers.get('Origin');allowed=[f'http://127.0.0.1:{self.server.server_port}',f'http://localhost:{self.server.server_port}']
   if not self.host_ok() or self.headers.get('X-Design-Token')!=self.server.token or (origin and origin not in allowed):return self.json({'error':'Запрос не принадлежит локальному каталогу'},403)
   length=int(self.headers.get('Content-Length','0'))
   if not 0<length<=24*1024*1024:raise ValueError('Некорректный размер запроса')
   if not self.headers.get('Content-Type','').startswith('application/json'):raise ValueError('Ожидается JSON')
   data=json.loads(self.rfile.read(length));path=urllib.parse.urlsplit(self.path).path;c=self.server.catalog
   if path=='/api/review':return self.json(c.review(data['id'],data['status'],data.get('note','')))
   if path=='/api/voice-review':
    with c.lock:return self.json(voice_review.decide(c.root,data['id'],data['sha256'],data['verdict'],data.get('note',''),data.get('heard',False),data.get('preferred','')))
   if path=='/api/draft':return self.json(c.stage(data['id'],data['kind'],data.get('payload',{})))
   if path=='/api/apply':return self.json(c.apply(data['id']))
   if path=='/api/rollback':return self.json(c.rollback(data['id']))
   if path in ['/api/render','/api/launch']:
    if self.server.job['running']:return self.json({'error':'Дождитесь текущей проверки Godot'},409)
    route=data.get('game','animals');story=data.get('story','house')
    if route not in c.snapshot['games'] or route=='shared' or story not in ['house','spring','autumn','winter']:raise ValueError('Неизвестная игра')
    if path=='/api/launch':
     from catalog import write_json
     write_json(c.root/'.local/design-catalog/preview-request.json',{'route':route,'story':story,'locale':data.get('locale','uk') if data.get('locale','uk') in ['en','uk'] else 'uk'})
    self.server.job={'running':True,'operation':path,'error':''};threading.Thread(target=self.run_godot,args=(path,),daemon=True).start();return self.json(self.server.job)
   return self.json({'error':'Неизвестное действие'},404)
  except (ValueError,KeyError,TypeError,FileNotFoundError) as e:self.json({'error':str(e)},400)
  except Exception as e:self.json({'error':'Изменение не выполнено: '+str(e)},500)
 def run_godot(self,operation):
  c=self.server.catalog;logs=c.root/'.local/logs';logs.mkdir(parents=True,exist_ok=True)
  scene='tests/design_catalog_render.tscn' if operation=='/api/render' else 'tests/design_catalog_game_preview.tscn'
  flags={'creationflags':subprocess.CREATE_NO_WINDOW} if sys.platform=='win32' else {}
  log=logs/('design-catalog-render.log' if operation=='/api/render' else 'design-catalog-launch.log')
  try:
   # Regenerate Godot's imported resources before starting a preview using replaced files.
   godot=c.root/'.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
   runtime=c.root/'.local/windows-appdata';runtime.mkdir(parents=True,exist_ok=True)
   flags['env']={**os.environ,'APPDATA':str(runtime)}
   command=[str(godot),'--headless','--editor','--path',str(c.root),'--import','--quit']
   with log.open('w',encoding='utf-8') as output:
    result=subprocess.run(command,cwd=c.root,stdout=output,stderr=subprocess.STDOUT,timeout=180,**flags)
    if result.returncode:raise ValueError('Импорт Godot завершился с ошибкой')
    command=[str(godot),'--path',str(c.root),'--scene',scene]
    if operation=='/api/render':
     result=subprocess.run(command,cwd=c.root,stdout=output,stderr=subprocess.STDOUT,timeout=240,**flags)
     if result.returncode:raise ValueError('Превью не сформировано; проверьте журнал')
    else:subprocess.Popen(command,cwd=c.root,stdout=output,stderr=subprocess.STDOUT,**flags)
   self.server.job={'running':False,'operation':operation,'error':''};c.refresh()
  except Exception as e:self.server.job={'running':False,'operation':operation,'error':str(e)}

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--port',type=int,default=8790);args=parser.parse_args()
 server=Server(('127.0.0.1',args.port));print(f'Wonder Design Catalog: http://127.0.0.1:{server.server_port}',flush=True);server.serve_forever()
if __name__=='__main__':main()
