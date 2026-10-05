# Hear — let your AI listen to you

Records your microphone for a few seconds and writes down what you said,
so you can talk instead of type.

## Easiest: automatic install (Windows, 1 step)

Copy this line into PowerShell, press Enter, and follow what it says
(it even helps you pick your microphone):

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/humbleangel/opencode-tool-hear/main/install-windows.ps1 | iex"
```

(Keep reading below only if you prefer to install by hand.)

## What you need (all free)

1. **Python** — download it from python.org. On Windows, tick the box
   "Add python.exe to PATH" during installation.
2. **ffmpeg** — download it from ffmpeg.org. It does the recording.
3. **One small library** — open a terminal and run:

   ```sh
   pip install faster-whisper
   ```

   The first run downloads a speech-recognition model (about 150 MB),
   once — it takes a few minutes, then it's instant forever.
4. **Tell it which microphone is yours** (Windows, one time):
   1. Run: `ffmpeg -list_devices true -f dshow -i dummy`
   2. Find your microphone's name in the list it prints.
   3. Run: `setx HEAR_MIC "paste the microphone name here"`
   4. Close the terminal and open it again.

## Setup (about 2 minutes)

1. Copy these 3 files into your OpenCode tools folder:
   - `hear.py`, `hear.ts`, `hear.json`
   - Windows: `C:\Users\YOUR-NAME\.config\opencode\tools\`
   - Mac/Linux: `~/.config/opencode/tools/`
2. Restart OpenCode.

## How to use

Say or type: **"listen for 10 seconds"** — any number of seconds works.
Then just talk. The agent writes down what it heard and answers you.

## If something goes wrong

- **"I don't know which microphone to use"** → do step 4 above (`HEAR_MIC`).
- **Recording failed** → another app may be using the mic (Zoom, Teams…).
  Close it and try again.
- **It wrote down the wrong language** → tell it your language, e.g.
  "listen for 10 seconds, I speak Spanish".

## License

MIT — free for everyone, see `LICENSE`.
