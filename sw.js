/* سجل المتابعة — Service Worker
   يخزّن ملفات التطبيق والموارد الخارجية عند أول فتح بإنترنت،
   ثم يعمل التطبيق بالكامل بلا إنترنت بعد ذلك. */
const CACHE='sijil-cache-v1';
const CORE=[
  './',
  './index.html',
  './manifest.json',
  './logo.png',
  './lib/fonts.css',
  './lib/jspdf.umd.min.js',
  './lib/html2canvas.min.js'
];
// موارد خارجية تُخزَّن عند أول طلب ناجح (احتياطي لو لم توجد ملفات lib محلياً)
const RUNTIME=[
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js',
  'https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800&display=swap'
];

self.addEventListener('install',e=>{
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c=>
    // نخزّن الأساسيات، ونتجاهل فشل أي ملف غير موجود (مثل lib) دون كسر التثبيت
    Promise.allSettled(CORE.map(u=>c.add(u).catch(()=>{})))
  ));
});

self.addEventListener('activate',e=>{
  e.waitUntil(caches.keys().then(keys=>
    Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k)))
  ).then(()=>self.clients.claim()));
});

self.addEventListener('fetch',e=>{
  const req=e.request;
  if(req.method!=='GET')return;
  // استراتيجية: الكاش أولاً، ثم الشبكة (ونخزّن ما نجلبه)
  e.respondWith(
    caches.match(req).then(cached=>{
      if(cached)return cached;
      return fetch(req).then(res=>{
        // خزّن نسخة من الموارد الخارجية والملفات المحلية
        const url=req.url;
        const store=url.startsWith(self.location.origin)||RUNTIME.some(r=>url.startsWith(r.split('?')[0]));
        if(store&&res&&(res.status===200||res.type==='opaque')){
          const copy=res.clone();caches.open(CACHE).then(c=>c.put(req,copy));
        }
        return res;
      }).catch(()=>cached);
    })
  );
});
