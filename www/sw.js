const CACHE_NAME = 'descent-planning-v65-cache-112';
const CORE_ASSETS = [
  './',
  './index.html',
  './privacy.html',
  './terms.html',
  './manifest.webmanifest',
  './icon.svg',
  './apple-touch-icon.png',
  './splash_bg.png'
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
    // First, try an exact cache hit. Then ignore query strings so cache-busting
    // URLs still work offline.
    const exact = await caches.match(req);
    if (exact) return exact;
    const loose = await caches.match(req, {ignoreSearch: true});
    if (loose) return loose;

    try {
      const resp = await fetch(req);
      if (resp && resp.ok) {
        const cache = await caches.open(CACHE_NAME);
        cache.put(req, resp.clone()).catch(()=>{});
      }
      return resp;
    } catch (err) {
      // Only fall back to the HTML shell for top-level navigations.
      if (req.mode === 'navigate') {
        return await caches.match('./index.html', {ignoreSearch: true});
      }
      return new Response('Offline asset not cached: ' + url.pathname, {status: 503});
    }
  })());
});
