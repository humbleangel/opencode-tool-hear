# opencode-tool-hear

OpenCode custom tool: microphone-to-text. Records for X seconds and returns the transcription. Blocks until recording + transcription finish.

## Files

- `hear.py` — reads `{seconds, language}` JSON from stdin, records via `ffmpeg` (dshow), transcribes with `faster-whisper` (`base`, cpu, int8)
- `hear.ts` — OpenCode plugin wrapper
- `hear.json` — tool manifest

## Params

- `seconds`: recording duration (default `5`)
- `language`: transcription language code (default `en`, use `pt` for Portuguese)

## Requirements

- Python 3.12+, `pip install faster-whisper`
- `ffmpeg` with dshow audio input (Windows)

## Usage

```json
{ "seconds": 10, "language": "pt" }
```

```sh
echo '{"seconds":5,"language":"pt"}' | python hear.py
```

Renamed from `ear` → `hear` to match its sibling `speak`.
