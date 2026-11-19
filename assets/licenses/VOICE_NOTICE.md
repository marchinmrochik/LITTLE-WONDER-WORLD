# Bundled speech attribution

The English and Ukrainian speech assets are synthesized WAV files. The synthesis engine and model weights are development dependencies.

| Voice model | Source documentation |
| --- | --- |
| Cori High (British English) | [Model card](cori-MODEL_CARD.txt) |
| LJ Speech High (American English) | [Model card](ljspeech-MODEL_CARD.txt) |
| Tetiana High (Ukrainian) | [Model card](tetiana-high-MODEL_CARD.md), [Apache 2.0 notice](tetiana-high-Apache-2.0.txt) |
| Ukrainian TTS Medium (Ukrainian) | [Model card](ukrainian-tts-medium-MODEL_CARD.txt) |
| Lada (Ukrainian) | [Model card](lada-MODEL_CARD.txt), [Apache 2.0 notice](lada-Apache-2.0.txt) |

See the [voice manifest](../audio/voice/manifest.json) for per-clip hashes and processing, the [Piper toolchain lock](../../tools/voice-toolchain.json) for model sources, and the [Piper license](piper-MIT.txt). Selected audio is preserved by [the override registry](../../tools/voice_clip_overrides.json).
