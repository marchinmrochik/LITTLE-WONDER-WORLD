"""Tests recognition triage and publication policy without claiming to hear speech."""
import json,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'));sys.path.insert(0,str(ROOT/'design_catalog'))
from audit_spoken_words import evaluate,normalized
from check_git_publish import path_problem
from audit_alphabet_quality import classify
import voice_review
from catalog import write_json,digest

class SemanticTests(unittest.TestCase):
 def test_alphabet_detects_extra_words_and_non_speech(self):
  signal={"review":False}
  self.assertEqual(classify("en","C","C.","See you.",signal),"asr_disagreement")
  self.assertEqual(classify("en","C","C.","See.",signal),"recognizer_consistent")
  self.assertEqual(classify("en","J","J.","[Music]",signal),"non_speech_asr")
  self.assertEqual(classify("uk","Е","е.","Ме.",signal),"asr_disagreement")
  self.assertEqual(classify("uk","Б","бе.","Бе.",signal),"recognizer_consistent")

 def test_wrong_word_is_never_a_match(self):
  clip={'locale':'en','key':'WORD_DUCK','text':'Duck.'}
  result=evaluate(clip,'Talk.');self.assertEqual(result['state'],'mismatch');self.assertFalse(result['human_approved'])
 def test_numbers_and_punctuation_have_only_explicit_equivalence(self):
  self.assertEqual(normalized('Five.','en'),normalized('5!','en'))
  self.assertEqual(normalized("П’ять.",'uk'),normalized('5','uk'))
  self.assertNotEqual(normalized('Bread.','en'),normalized('Red.','en'))
 def test_letters_and_empty_results_require_review(self):
  self.assertEqual(evaluate({'locale':'en','key':'ALPH_EN_25','text':'Z.'},'Z.')['state'],'letter_manual')
  self.assertEqual(evaluate({'locale':'uk','key':'WORD_CAT','text':'Кіт'},'')['state'],'unrecognized')
 def test_asr_match_never_creates_listening_approval(self):
  self.assertFalse(evaluate({'locale':'en','key':'WORD_CAT','text':'Cat.'},'Cat')['human_approved'])
 def test_stale_asr_is_not_displayed_as_current(self):
  with tempfile.TemporaryDirectory() as folder:
   root=Path(folder);file=root/'assets/audio/voice/manifest.json';file.parent.mkdir(parents=True);file.write_bytes(b'{}');sha=digest(b'clip')
   row={'id':'en:TEST','locale':'en','key':'TEST','sha256':sha}
   write_json(root/'.local/qa/f01/audit.json',{'manifest_sha256':digest(b'{}'),'clips':[row]})
   write_json(root/'.local/qa/voice-asr/asr.json',{'manifest_sha256':digest(b'{}'),'clips':[{**row,'state':'match','transcript':'test'}]})
   result=voice_review.snapshot(root)['clips'][0]
   self.assertEqual(result['asr']['state'],'match');self.assertEqual(result['review']['verdict'],'unreviewed')
   row['sha256']=digest(b'changed');write_json(root/'.local/qa/f01/audit.json',{'manifest_sha256':digest(b'{}'),'clips':[row]})
   self.assertEqual(voice_review.snapshot(root)['clips'][0]['asr']['state'],'not_checked')
 def test_private_art_and_models_are_blocked_without_hiding_runtime_media(self):
  for path in ['.local/tablet-backups/save.tar','.tools/whisper/model.bin','build/app.apk','assets/ggml-base.bin','.env.production','secret.keystore']:
   self.assertTrue(path_problem(path),path)
  for path in ['assets/audio/voice/en/word_cat.wav','assets/objects/animals/dog.svg','assets/people.png','data/localization/uk.json','.env.example']:
   self.assertFalse(path_problem(path),path)

if __name__=='__main__':unittest.main()
