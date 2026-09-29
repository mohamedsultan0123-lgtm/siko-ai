$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host 'Flutter was not found in PATH. Install Flutter and make sure `flutter --version` works in a new terminal.' -ForegroundColor Red
  exit 1
}

Write-Host 'Generating Android platform files...' -ForegroundColor Cyan
flutter create --platforms android --project-name siko_ai .

$manifest = Join-Path (Get-Location) 'android\app\src\main\AndroidManifest.xml'
if (Test-Path $manifest) {
  $content = Get-Content $manifest -Raw

  $permissions = @(
    '    <uses-permission android:name="android.permission.RECORD_AUDIO" />',
    '    <uses-permission android:name="android.permission.INTERNET" />',
    '    <uses-permission android:name="android.permission.BLUETOOTH" />',
    '    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />',
    '    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />'
  ) -join "`n"

  if ($content -notmatch 'android.permission.RECORD_AUDIO') {
    $content = $content -replace '(<manifest[^>]*>)', "`$1`n$permissions"
  }

  if ($content -notmatch 'android.speech.RecognitionService') {
    $queryBlock = @"
    <queries>
        <intent>
            <action android:name="android.speech.RecognitionService" />
        </intent>
        <intent>
            <action android:name="android.intent.action.TTS_SERVICE" />
        </intent>
    </queries>
"@
    $content = $content -replace '(</manifest>)', "$queryBlock`$1"
  } elseif ($content -notmatch 'android.intent.action.TTS_SERVICE') {
    $content = $content -replace '(</queries>)', '        <intent>`n            <action android:name="android.intent.action.TTS_SERVICE" />`n        </intent>`n    $1'
  }

  $content = $content -replace 'android:label="[^"]*"', 'android:label="Siko AI"'
  Set-Content -Path $manifest -Value $content -Encoding UTF8
}

Write-Host 'Running flutter pub get...' -ForegroundColor Cyan
flutter pub get

Write-Host ''
Write-Host 'Setup complete. Connect an Android 10+ phone, enable USB debugging, and run:' -ForegroundColor Green
Write-Host '  flutter devices'
Write-Host '  flutter run'
