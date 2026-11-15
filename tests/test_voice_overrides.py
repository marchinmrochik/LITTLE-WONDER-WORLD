import hashlib,json
from pathlib import Path
import sys,tempfile,unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from voice_overrides import preserve_approved

class VoiceOverrideTests(unittest.TestCase):
 def test_selected_audio_is_preserved_while_other_jobs_remain(self):
  with tempfile.TemporaryDirectory() as folder:
   root=Path(folder);(root/'tools').mkdir();(root/'selected.wav').write_bytes(b'approved')
   sha=hashlib.sha256(b'approved').hexdigest();(root/'tools/voice_clip_overrides.json').write_text(json.dumps({'clips':{'en:WORD_SHEEP':{'sha256':sha}}}))
   job={'key':'WORD_SHEEP','file':'selected.wav','text':'Sheep.'};clip={**job,'locale':'en','sha256':sha,'voice_override':{'variant':'ljspeech'}}
   other={'key':'WORD_CAT','file':'cat.wav','text':'Cat.'}
   jobs,preserved=preserve_approved(root,{'en':[job,other]},{'clips':[clip]})
   self.assertEqual(jobs,{'en':[other]});self.assertEqual(preserved,[clip]);self.assertEqual((root/'selected.wav').read_bytes(),b'approved')
   with self.assertRaises(ValueError):preserve_approved(root,{'en':[{**job,'text':'Different.'}]},{'clips':[clip]})
   (root/'selected.wav').write_bytes(b'external edit')
   with self.assertRaises(ValueError):preserve_approved(root,{'en':[job]},{'clips':[clip]})
 def test_repair_pins_are_protected_without_claiming_human_approval(self):
  with tempfile.TemporaryDirectory() as folder:
   root=Path(folder);(root/"tools").mkdir();(root/"fixed.wav").write_bytes(b"repaired")
   sha=hashlib.sha256(b"repaired").hexdigest()
   (root/"tools/voice_repair_pins.json").write_text(json.dumps({"clips":{"uk:TEST":{"sha256":sha,"listening_status":"unreviewed"}}}))
   job={"key":"TEST","file":"fixed.wav","text":"Test."};clip={**job,"locale":"uk","sha256":sha}
   jobs,preserved=preserve_approved(root,{"uk":[job]},{"clips":[clip]})
   self.assertEqual(jobs,{"uk":[]});self.assertEqual(preserved,[clip])
   self.assertFalse((root/"tools/voice_clip_overrides.json").exists())

 def test_missing_config_keeps_all_jobs(self):
  with tempfile.TemporaryDirectory() as folder:
   jobs={'en':[{'key':'TEST'}]};self.assertEqual(preserve_approved(Path(folder),jobs,{'clips':[]}),(jobs,[]))

if __name__=='__main__':unittest.main()
