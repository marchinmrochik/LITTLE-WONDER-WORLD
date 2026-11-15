"""SVG coverage/state/guide validation for all four native story boards."""
import json
from pathlib import Path
import sys
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'design_catalog'))
from catalog import validate_image

class StoryIllustrationTests(unittest.TestCase):
 def test_every_story_part_has_a_real_self_contained_texture(self):
  registry=json.loads((ROOT/'data/game_content/design_visual_overrides.json').read_text(encoding='utf-8'))['overrides']
  expected=set()
  for story in ['house','spring','autumn','winter']:
   data=json.loads((ROOT/f'data/game_content/living_{story}.json').read_text(encoding='utf-8'))
   for part in data['parts']:
    key=f"story/{story}/{part['id']}";expected.add(key);entry=registry[key]
    for texture in [entry['texture'],*entry.get('variants',{}).values()]:
     self.assertTrue(texture.startswith('res://assets/'))
     file=(ROOT/texture.removeprefix('res://')).resolve();self.assertTrue(file.is_relative_to((ROOT/'assets').resolve()));self.assertTrue(file.is_file())
     validate_image(file.read_bytes(),'.svg')
    if story!='house':
     x,y,w,h=part['zoom']
     for stroke in part['strokes']:
      self.assertGreaterEqual(len(stroke),2)
      for a,b in stroke:self.assertTrue(x<=a<=x+w and y<=b<=y+h,(story,part['id'],a,b))
  self.assertEqual(set(registry),expected);self.assertEqual(len(expected),46)
 def test_companion_reuse_and_light_variants(self):
  registry=json.loads((ROOT/'data/game_content/design_visual_overrides.json').read_text(encoding='utf-8'))['overrides']
  self.assertTrue(registry['story/house/dog']['texture'].endswith('/animals/dog.svg'))
  self.assertTrue(registry['story/spring/bunny']['texture'].endswith('/animals/rabbit.svg'))
  self.assertNotEqual(registry['story/house/left_window']['texture'],registry['story/house/left_window']['variants']['active'])
  self.assertIn('night',registry['story/winter/cottage']['variants']);self.assertIn('active',registry['story/winter/lantern']['variants'])
  self.assertTrue(registry['story/winter/moon']['texture'].endswith('/moon.svg'))

if __name__=='__main__':unittest.main()
