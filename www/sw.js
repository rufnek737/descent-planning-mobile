const CACHE_NAME = 'descent-planning-v65-cache-62';
const CORE_ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icon.svg',
  './apple-touch-icon.png',
  './splash_bg.png',
  './vendor/pdf.min.js',
  './vendor/pdf.worker.min.js',
  './vendor/tesseract.min.js',
  './vendor/worker.min.js',
  // Tesseract core: JS wrappers AND their matching .wasm binaries are both required
  // offline. Tesseract.js detects browser capabilities (SIMD / LSTM) at runtime and
  // loads whichever variant fits, so all four variants must be cached or OCR fails
  // the moment the network is unavailable.
  './vendor/tesseract-core.wasm.js',
  './vendor/tesseract-core.wasm',
  './vendor/tesseract-core-simd.wasm.js',
  './vendor/tesseract-core-simd.wasm',
  './vendor/tesseract-core-lstm.wasm.js',
  './vendor/tesseract-core-lstm.wasm',
  './vendor/tesseract-core-simd-lstm.wasm.js',
  './vendor/tesseract-core-simd-lstm.wasm',
  './vendor/tessdata/eng.traineddata.gz'
];

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    for (const asset of CORE_ASSETS) {
      try {
        await cache.add(new Request(asset, {cache: 'reload'}));
      } catch (err) {
        console.warn('[SW] cache skip', asset, err);
      }
    }
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map(k => k !== CACHE_NAME ? caches.delete(k) : null));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  event.respondWith((async () => {
    // First, try an exact cache hit. Then ignore query strings so pdf.min.js?v=...
    // or browser-generated cache-busting URLs still work offline.
    const exact = await caches.match(req);
    if (exact) return exact;
    const loose = await caches.match(req, {ignoreSearch: true});
    if (loose) return loose;
    // Home-screen iOS sometimes asks for an absolute http://IP:PORT/vendor/... URL
    // while the app itself is served from cache.  Match by relative vendor path.
    const relPath = url.pathname.includes('/vendor/') ? './vendor/' + url.pathname.split('/vendor/').pop() : url.pathname.replace(/^\//,'./');
    if (relPath.startsWith('./vendor/')) {
      const vendorHit = await caches.match(relPath, {ignoreSearch:true});
      if (vendorHit) return vendorHit;
      // pdf.js spawns the worker via the same origin, but the worker itself may then
      // fetch sub-paths like /vendor/pdf.worker.min.js via an absolute URL with a
      // hash/port mismatch. Match by basename as a last resort so the worker boots.
      const base = relPath.split('/').pop();
      const keys = await caches.keys();
      for (const k of keys) {
        const c = await caches.open(k);
        const reqs = await c.keys();
        const m = reqs.find(r => r.url.endsWith('/vendor/' + base));
        if (m) {
          const r = await c.match(m);
          if (r) return r;
        }
      }
    }

    try {
      const resp = await fetch(req);
      if (resp && resp.ok) {
        const cache = await caches.open(CACHE_NAME);
        cache.put(req, resp.clone()).catch(()=>{});
      }
      return resp;
    } catch (err) {
      // Only fall back to the HTML shell for top-level navigations.
      // Vendor / worker requests must NOT get index.html — that would be evaluated
      // as JavaScript by pdf.js or tesseract and break the parser silently.
      if (req.mode === 'navigate') {
        return await caches.match('./index.html', {ignoreSearch: true});
      }
      return new Response('Offline asset not cached: ' + url.pathname, {status: 503});
    }
  })());
});
