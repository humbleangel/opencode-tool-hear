#!/usr/bin/env python3
"""
Microphone-to-text tool.

Reads JSON input from stdin:
    {"seconds": 5, "language": "en"}

Records from the microphone via ffmpeg, transcribes with
faster-whisper, and prints JSON to stdout:
    {"success": true, "text": "..."}

Set HEAR_MIC to your input device name. List devices with:
    ffmpeg -list_devices true -f dshow -i dummy
"""

import json
import os
import subprocess
import sys
import tempfile

MIC = os.environ.get("HEAR_MIC", "").strip()


def main() -> int:
    try:
        data = json.loads(sys.stdin.read().strip() or "{}")
    except json.JSONDecodeError as e:
        print(json.dumps({"success": False, "message": f"Invalid JSON: {e}"}))
        return 1

    seconds = int(data.get("seconds", 5))
    language = data.get("language", "en")

    if not MIC:
        print(json.dumps({"success": False, "message": "I don't know which microphone to use. Set the HEAR_MIC environment variable to your microphone name. List devices with: ffmpeg -list_devices true -f dshow -i dummy"}))
        return 1

    wav = os.path.join(tempfile.gettempdir(), "hear_in.wav")
    try:
        rec = subprocess.run(
            [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-f",
                "dshow",
                "-i",
                f"audio={MIC}",
                "-ar",
                "16000",
                "-ac",
                "1",
                "-t",
                str(seconds),
                wav,
            ],
            capture_output=True,
        )
        if rec.returncode != 0:
            msg = rec.stderr.decode(errors="ignore")[-200:]
            print(json.dumps({"success": False, "message": f"Recording failed: {msg}"}))
            return 1

        from faster_whisper import WhisperModel

        segments, _ = WhisperModel(
            "base", device="cpu", compute_type="int8"
        ).transcribe(wav, language=language)
        text = "".join(s.text for s in segments)
        print(json.dumps({"success": True, "text": text}))
        return 0
    except Exception as e:
        print(json.dumps({"success": False, "message": str(e)}))
        return 1
    finally:
        if os.path.exists(wav):
            os.remove(wav)


if __name__ == "__main__":
    sys.exit(main())
