@echo off
REM تجهيز التطبيق للعمل بلا انترنت — يشغّل مرة واحدة بوجود اتصال.
cd /d "%~dp0"
if not exist lib mkdir lib
echo » تنزيل مكتبات PDF...
powershell -Command "Invoke-WebRequest 'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js' -OutFile 'lib\jspdf.umd.min.js'"
powershell -Command "Invoke-WebRequest 'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js' -OutFile 'lib\html2canvas.min.js'"
echo » تنزيل الخط العربي...
powershell -Command "$css = Invoke-WebRequest 'https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800&display=swap' -UserAgent 'Mozilla/5.0'; $css = $css.Content; if(!(Test-Path 'lib\fonts')){New-Item -ItemType Directory 'lib\fonts' | Out-Null}; $urls = [regex]::Matches($css,'url\((https://[^)]+\.woff2)\)') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique; $i=0; foreach($u in $urls){ $fn = 'fonts/tajawal-' + $i + '.woff2'; try { Invoke-WebRequest $u -OutFile ('lib/' + $fn) -UserAgent 'Mozilla/5.0'; $css = $css.Replace($u, $fn); $i++ } catch {} }; Set-Content -Path 'lib\fonts.css' -Value $css -Encoding UTF8; Write-Host ('  تم تضمين ' + $i + ' ملف خط.') "
echo.
echo تم التجهيز. التطبيق الان يعمل بلا انترنت بالكامل.
pause
