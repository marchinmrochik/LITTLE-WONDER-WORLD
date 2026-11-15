"""Listening approval is manual, local and tied to exact audio bytes."""
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'design_catalog'));sys.path.insert(0,str(ROOT/'tools'))
import voice_review
from catalog import digest,write_json
from audit_voice_content import normalized, make_audit

class VoiceReviewTests(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory();self.root=Path(self.temp.name)
  file=self.root/'assets/audio/voice/en/test.wav';file.parent.mkdir(parents=True);file.write_bytes(b'fixture')
  self.sha=digest(file.read_bytes());manifest=file.parent.parent/'manifest.json';manifest.write_bytes(b'{}')
  write_json(self.root/'.local/qa/f01/audit.json',{'manifest_sha256':digest(b'{}'),'clips':[{'id':'en:TEST','locale':'en','key':'TEST','sha256':self.sha,'file':'assets/audio/voice/en/test.wav'}]})
 def tearDown(self):self.temp.cleanup()
 def test_no_automatic_approval(self):
  self.assertEqual(voice_review.snapshot(self.root)['clips'][0]['review']['verdict'],'unreviewed')
  with self.assertRaises(ValueError):voice_review.decide(self.root,'en:TEST',self.sha,'good')
 def test_roundtrip_and_stale_hash(self):
  voice_review.decide(self.root,'en:TEST',self.sha,'bad','Wrong word',True)
  self.assertEqual(voice_review.snapshot(self.root)['clips'][0]['review']['verdict'],'bad')
  (self.root/'assets/audio/voice/manifest.json').write_bytes(b'{"changed":1}')
  self.assertEqual(voice_review.snapshot(self.root)['clips'][0]['review']['verdict'],'unreviewed')
  with self.assertRaises(ValueError):voice_review.decide(self.root,'en:TEST',self.sha,'good','',True)
 def test_changed_audio_rejected(self):
  (self.root/'assets/audio/voice/en/test.wav').write_bytes(b'changed')
  with self.assertRaises(ValueError):voice_review.decide(self.root,'en:TEST',self.sha,'good','',True)
 def test_unknown_record_variant_and_verdict(self):
  for identity,verdict,preferred in [('en:OTHER','good',''),('en:TEST','automatic',''),('en:TEST','good','unknown')]:
   with self.assertRaises(ValueError):voice_review.decide(self.root,identity,self.sha,verdict,'',True,preferred)
  with self.assertRaises(ValueError):voice_review.candidate(self.root,'../outside','en','TEST')
 def test_text_matching(self):
  self.assertEqual(normalized('Cat'),normalized('Cat.'))
  self.assertNotEqual(normalized('Draw walls.'),normalized('Draw walls. Extra words.'))
 def test_candidate_preference_expires_when_variant_changes(self):
  path=self.root/'.local/qa/f01/candidates/test.wav';path.parent.mkdir(parents=True);path.write_bytes(b'candidate')
  entry={'locale':'en','key':'TEST','variant':'candidate','file':path.relative_to(self.root).as_posix(),'sha256':digest(b'candidate')}
  pack={'manifest_sha256':digest(b'{}'),'variants':[],'samples':[entry]}
  write_json(self.root/'.local/qa/f01/comparison.json',pack)
  voice_review.decide(self.root,'en:TEST',self.sha,'good','',True,'candidate')
  self.assertEqual(voice_review.snapshot(self.root)['clips'][0]['review']['verdict'],'good')
  path.write_bytes(b'new candidate');entry['sha256']=digest(path.read_bytes());write_json(self.root/'.local/qa/f01/comparison.json',pack)
  self.assertEqual(voice_review.snapshot(self.root)['clips'][0]['review']['verdict'],'unreviewed')
 def test_real_pack(self):
  data=make_audit(ROOT)
  self.assertEqual(data['counts'],{'en':341,'uk':369});self.assertEqual(data['errors'],[])
  for locale in ['en','uk']:
   for key in ['WORD_CAT','WORD_SHEEP','WORD_BEAR','COLOR_WORD_RED','FOOD_WORD_BREAD','COUNT_NUMBER_5','WORLD_BODY_FOOT_WORD']:
    row=next(r for r in data['clips'] if r['locale']==locale and r['key']==key)
    self.assertTrue(row['priority']);self.assertEqual(row['listening_status'],'unreviewed')

if __name__=='__main__':unittest.main()
