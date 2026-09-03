#!/usr/bin/env bash
# تجهيز التطبيق للعمل بلا إنترنت — يُشغّل مرة واحدة بوجود اتصال.
# ينزّل مكتبات PDF والخط العربي داخل مجلد lib/ ليعمل التطبيق مستقلاً تماماً.
set -e
cd "$(dirname "$0")"
mkdir -p lib
echo "» تنزيل مكتبات PDF..."
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js" -o lib/jspdf.umd.min.js
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js" -o lib/html2canvas.min.js
echo "» تنزيل الخط العربي (Tajawal)..."
# نجلب أوزان الخط ونبني ملف fonts.css محلي
BASE="https://fonts.gstatic.com/s/tajawal"
declare -A W=( [400]="v9/Iura6YBj_oCad4k1l5qw" [500]="v9/Iurf6YBj_oCad4k1nzGBC5Q" [700]="v9/Iurf6YBj_oCad4k1nzGBC5Q" [800]="v9/Iurf6YBj_oCad4k1nzGBC5Q" )
# طريقة أبسط وأضمن: نجلب ملف CSS من غوغل ثم الخطوط المشار إليها
curl -fsSL "https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800&display=swap" \
  -H "User-Agent: Mozilla/5.0" -o lib/_google.css
# استخرج روابط woff2 ونزّلها وبدّلها بمسارات محلية
python3 - <<'PY'
import re,urllib.request,os
css=open('lib/_google.css',encoding='utf-8').read()
urls=re.findall(r'url\((https://[^)]+\.woff2)\)',css)
os.makedirs('lib/fonts',exist_ok=True)
seen={}
for i,u in enumerate(dict.fromkeys(urls)):
    fn=f'fonts/tajawal-{i}.woff2'
    try:
        req=urllib.request.Request(u,headers={'User-Agent':'Mozilla/5.0'})
        open('lib/'+fn,'wb').write(urllib.request.urlopen(req).read())
        seen[u]=fn
    except Exception as e:
        print('  تعذّر تنزيل خط:',e)
for u,fn in seen.items():
    css=css.replace(u,fn)
open('lib/fonts.css','w',encoding='utf-8').write(css)
print(f'  تم تضمين {len(seen)} ملف خط.')
PY
rm -f lib/_google.css
echo "✔ تم التجهيز. التطبيق الآن يعمل بلا إنترنت بالكامل."
