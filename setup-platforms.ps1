$ErrorActionPreference = 'Stop'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter غير موجود في PATH. ثبّت Flutter SDK وافتح PowerShell جديداً ثم نفّذ flutter doctor.'
}

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$platformNames = @('android', 'ios', 'web')
$existing = @($platformNames | Where-Object { Test-Path (Join-Path $projectRoot $_) })

Push-Location $projectRoot
try {
  if ($existing.Count -eq $platformNames.Count) {
    Write-Host 'مجلدات المنصات موجودة في جذر مشروع Flutter؛ لن أُعيد توليدها أو أغيّرها.' -ForegroundColor Cyan
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get انتهى برمز $LASTEXITCODE" }
    Write-Host 'اكتمل تجهيز الحزم.' -ForegroundColor Green
    return
  }
  if ($existing.Count -gt 0) {
    throw "بعض مجلدات المنصات موجودة فقط ($($existing -join ', ')). لن أكتب فوق إعدادات جزئية؛ أكمل إنشاء المنصات يدوياً بعد نسخة احتياطية."
  }

  $backup = Join-Path $env:TEMP ("sekretiri-flutter-preserve-" + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $backup | Out-Null
  $preserved = @('lib', 'assets', 'pubspec.yaml', 'analysis_options.yaml', 'test')
  foreach ($entry in $preserved) {
    $source = Join-Path $projectRoot $entry
    if (Test-Path $source) { Copy-Item $source -Destination $backup -Recurse -Force }
  }

  try {
    flutter create --no-pub --project-name sekretiri_flutter --platforms=android,ios,web .
    if ($LASTEXITCODE -ne 0) { throw "flutter create انتهى برمز $LASTEXITCODE" }
    foreach ($entry in $preserved) {
      $saved = Join-Path $backup $entry
      if (Test-Path $saved) { Copy-Item $saved -Destination $projectRoot -Recurse -Force }
    }
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get انتهى برمز $LASTEXITCODE" }
    Write-Host 'اكتمل إنشاء مجلدات Android/iOS/Web وجلب الحزم.' -ForegroundColor Green
  } finally {
    Remove-Item $backup -Recurse -Force -ErrorAction SilentlyContinue
  }
} finally {
  Pop-Location
}
