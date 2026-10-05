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

## First interaction

When both tools are loaded, the agent on the very first interaction speaks aloud (via speak) that it can talk and listen, explains how to ask to be heard: `ouça por X segundos` / `listen for X seconds`, and asks if the user wants always-speak-and-listen as the default for every interaction (this instruction lives in the tool descriptions, so it ships with the tools).

## License

MIT — free for anyone to use, see `LICENSE`.
