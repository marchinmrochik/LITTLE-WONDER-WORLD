"""Catalog mutations run only against disposable project fixtures."""
import base64
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'design_catalog'))
from catalog import Catalog, inventory, safe, validate_image, validate_strokes


class CatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        cls.root = Path(cls.temp.name)
        for directory in ['data', 'scripts', 'scenes']:
            shutil.copytree(ROOT / directory, cls.root / directory)
        shutil.copy2(ROOT / 'project.godot', cls.root / 'project.godot')
        (cls.root / 'assets').mkdir()
        (cls.root / 'assets/test.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg"/>')
        cls.catalog = Catalog(cls.root)

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def test_inventory(self):
        data = self.catalog.refresh()
        self.assertEqual(data['stats']['procedural'], 46)
        self.assertEqual(data['stats']['screens'], 15)
        self.assertEqual(sum(e['type'] == 'trace' for e in data['entries']), 69)
        self.assertEqual(len({e['id'] for e in data['entries']}), len(data['entries']))

    def exercise(self, entry_id, kind, payload):
        c = self.catalog
        e = c.entry(entry_id)
        target = self.root / e['path']
        before = target.read_bytes()
        draft = c.stage(entry_id, kind, payload)
        self.assertEqual(target.read_bytes(), before)
        journal = c.apply(draft['id'])
        self.assertTrue(journal['files'])
        c.rollback(draft['id'])
        self.assertEqual(target.read_bytes(), before)
        with self.assertRaises(ValueError):
            c.rollback(draft['id'])

    def test_color_apply_and_rollback(self):
        entry = next(e for e in self.catalog.snapshot['entries'] if e['type'] == 'token')
        self.exercise(entry['id'], 'color', {'color': '#123456'})

    def test_trace_apply_and_rollback(self):
        self.exercise('procedural:story/autumn/hedgehog', 'trace', {'strokes': [[[0, 0], [15, 20]]]})

    def test_letter_trace_apply_and_rollback(self):
        self.exercise('symbol:letters:uk:0', 'trace', {'strokes': [[[0, 0], [15, 20]]]})

    def test_file_apply_and_rollback(self):
        self.exercise('asset:assets/test.svg', 'file', {'extension': '.svg', 'source_note': 'Fixture', 'base64': base64.b64encode(b'<svg xmlns="http://www.w3.org/2000/svg"><circle r="3"/></svg>').decode()})

    def test_art_apply_and_rollback(self):
        registry = self.root / 'data/game_content/design_visual_overrides.json'
        before = registry.read_bytes()
        self.exercise('procedural:story/autumn/hedgehog', 'art', {'extension': '.svg', 'source_note': 'Fixture', 'base64': base64.b64encode(b'<svg xmlns="http://www.w3.org/2000/svg"/>').decode()})
        self.assertEqual(registry.read_bytes(), before)
        self.assertFalse((self.root / 'assets/design/overrides/story_autumn_hedgehog.svg').exists())

    def test_conflicts(self):
        c = self.catalog
        e = next(e for e in c.snapshot['entries'] if e['type'] == 'token')
        p = self.root / e['path']; before = p.read_bytes()
        with self.assertRaises(ValueError):
            c.stage(e['id'], 'color', {'color': '#123456', 'expected_sha': 'stale'})
        draft = c.stage(e['id'], 'color', {'color': '#123456'})
        try:
            p.write_bytes(before + b'\n# external edit\n')
            with self.assertRaises(ValueError): c.apply(draft['id'])
        finally: p.write_bytes(before)
        c.apply(draft['id']); applied = p.read_bytes()
        try:
            p.write_bytes(applied + b'\n# external edit\n')
            with self.assertRaises(ValueError): c.rollback(draft['id'])
        finally: p.write_bytes(applied)
        c.rollback(draft['id'])

    def test_validation_and_paths(self):
        for strokes in [[], [[[0, 0], [0, 0]]], [[[0, 0], [float('nan'), 2]]]]:
            with self.assertRaises(ValueError): validate_strokes(strokes)
        for svg in [b'<svg><script/></svg>', b'<svg onload="x"/>', b'<svg><image href="https://example.com/x"/></svg>', b'<!DOCTYPE svg><svg/>']:
            with self.assertRaises(ValueError): validate_image(svg, '.svg')
        with self.assertRaises(ValueError): validate_image(b'fake png', '.png')
        with self.assertRaises(ValueError): safe(self.root, '../outside')
        with self.assertRaises(ValueError): self.catalog.source('project.godot')
        with self.assertRaises(ValueError): self.catalog.load_draft('../outside')


if __name__ == '__main__':
    unittest.main()
