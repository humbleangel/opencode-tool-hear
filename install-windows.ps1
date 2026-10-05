# Hear tool - automatic Windows installer.
# Run this line in PowerShell and follow what it says:
# powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/humbleangel/opencode-tool-hear/main/install-windows.ps1 | iex"
$ErrorActionPreference = "Stop"
$Repo = "humbleangel/opencode-tool-hear"
$Files = @("hear.py", "hear.ts", "hear.json")
$ToolsDir = Join-Path $HOME ".config\opencode\tools"

Write-Host ""
Write-Host "=== Hear tool installer ==="
Write-Host "This will check Python, install the recorder and the listening library,"
Write-Host "copy the 3 tool files, and help you pick your microphone."
Write-Host ""

function Refresh-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  Write-Host "Python not found. Trying to install it automatically..."
  try {
    winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
    Refresh-Path
  } catch {
    Write-Host "Automatic install did not work."
    Write-Host "Please install Python from https://www.python.org/downloads/ (tick 'Add python.exe to PATH'),"
    Write-Host "then run this installer again."
    exit 1
  }
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  Write-Host "Python was installed, but this window cannot see it yet."
  Write-Host "Close this window, open a new one, and run the installer again."
  exit 1
}
python --version

Write-Host "Installing the listening library (one time)..."
python -m pip install --upgrade faster-whisper

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
  Write-Host "Recorder (ffmpeg) not found. Trying to install it automatically..."
  try {
    winget install -e --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements
    Refresh-Path
  } catch {
    Write-Host "Automatic install did not work."
    Write-Host "Please install ffmpeg from https://ffmpeg.org/download.html,"
    Write-Host "then run this installer again."
    exit 1
  }
}

Write-Host "Copying the tool files..."
New-Item -ItemType Directory -Path $ToolsDir -Force | Out-Null
foreach ($f in $Files) {
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/$Repo/main/$f" -OutFile (Join-Path $ToolsDir $f)
  Write-Host "  installed $f"
}

Write-Host ""
Write-Host "Now let's find your microphone..."
$raw = ffmpeg -list_devices true -f dshow -i dummy 2>&1 | Out-String
$names = @([regex]::Matches($raw, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
$picked = ""
if ($names.Count -eq 0) {
  Write-Host "I could not list your devices."
  $picked = Read-Host "Paste your microphone name exactly as Windows shows it"
} else {
  Write-Host "Which one is your microphone?"
  for ($i = 0; $i -lt $names.Count; $i++) {
    Write-Host ("  [{0}] {1}" -f ($i + 1), $names[$i])
  }
  Write-Host "  [0] None of these - I will type the name myself"
  $choice = Read-Host "Type the number"
  $n = 0
  if ([int]::TryParse($choice, [ref]$n) -and $n -ge 1 -and $n -le $names.Count) {
    $picked = $names[$n - 1]
  } elseif ($choice -eq "0") {
    $picked = Read-Host "Paste your microphone name exactly as Windows shows it"
  } else {
    Write-Host "That did not look like a number from the list. Run the installer again when ready."
    exit 1
  }
}
if ($picked) {
  setx HEAR_MIC $picked | Out-Null
  Write-Host "Microphone saved."
}

Write-Host ""
Write-Host "Done! Close this window, open a new one, then restart OpenCode."
Write-Host "To be heard, just say or type: listen for 10 seconds."
