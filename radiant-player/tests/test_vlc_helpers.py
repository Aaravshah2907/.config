#!/usr/bin/env python3
import importlib.util
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("radiant_queue", ROOT / "queue.py")
radiant_queue = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(radiant_queue)


class VlcHelperTests(unittest.TestCase):
    def test_clean_response_strips_prompts_and_blanks(self):
        raw = "\n> \n( state playing )\n\n> \n"
        self.assertEqual(radiant_queue.vlc_clean_response(raw), "( state playing )")

    def test_parse_status_extracts_state_and_volume(self):
        raw = "( state paused )\n( audio volume: 192 )"
        self.assertEqual(
            radiant_queue.vlc_parse_status(raw),
            {"state": "paused", "volume": 192},
        )

    def test_parse_status_defaults_missing_values(self):
        self.assertEqual(
            radiant_queue.vlc_parse_status("something unexpected"),
            {"state": "stopped", "volume": None},
        )

    def test_clean_title_handles_file_uri_and_plain_path(self):
        self.assertEqual(
            radiant_queue.vlc_clean_title("file:///tmp/My%20Song.flac"),
            "My Song.flac",
        )
        self.assertEqual(
            radiant_queue.vlc_clean_title("/tmp/Another Song.mp3"),
            "Another Song.mp3",
        )

    def test_clean_title_treats_no_input_as_empty(self):
        self.assertEqual(radiant_queue.vlc_clean_title("( no input )"), "")
        self.assertEqual(radiant_queue.vlc_clean_title(">"), "")

    def test_file_mrl_escapes_spaces(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "track with spaces.mp3"
            mrl = radiant_queue.vlc_file_mrl(str(path))
        self.assertTrue(mrl.startswith("file://"))
        self.assertIn("track%20with%20spaces.mp3", mrl)


if __name__ == "__main__":
    unittest.main()
