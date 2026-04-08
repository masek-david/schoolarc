// Source:
// https://medium.com/@adhilkrishnag/boosting-flutter-web-performance-caching-with-service-workers-d72d08a44c10
// https://web.dev/learn/pwa


// we cache remote sources - like some font from google, canvaskit.js, convaskit.wasm,... - with max cache time of 1 year,
// all other things are cached using service-worker.js

const CACHE_NAME = 'schoolarc-v2';
const API_CACHE = 'api-cache-v2';

const ASSETS_TO_CACHE = [
   '/',
   '/index.html',
   '/styles.css',
   '/main.dart.js',
   '/flutter_bootstrap.js',
   '/flutter.js',
   '/manifest.json',
   '/favicon.png',
   '/assets/AssetManifest.json',
   '/assets/FontManifest.json',
   '/assets/fonts/MaterialIcons-Regular.otf',
   '/version.json',
   // My assets
   '/assets/assets/book.svg',
   '/assets/assets/confetti.svg',
   '/assets/assets/changelog.md',
   '/assets/assets/pen.svg',
   '/assets/assets/schoolarc_icon.svg',
   '/assets/assets/schoolarc_logo.svg',
   '/assets/assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf',
   '/assets/assets/fonts/RobotoSerif-VariableFont_GRAD,opsz,wdth,wght.ttf',
   '/icons/Icon-192.png',
   '/icons/Icon-512.png',
];

// Install: Cache assets
self.addEventListener('install', (event) => {
   event.waitUntil(
      caches.open(CACHE_NAME)
         .then((cache) => {
            return cache.addAll(ASSETS_TO_CACHE);
         })
   );
   self.skipWaiting();
});

// Stale while revalidate API
self.addEventListener('fetch', event => {
   if (event.request.url.includes('gstatic.com')) {
      return;
   }

   // TODO staleandrevalidate too
   if (event.request.url.includes('version.json')) {
      event.respondWith(
         caches.match('/version.json')
            .then(cachedResponse => {
               return cachedResponse || fetch(event.request);
            }
            )
      )
      return;
   }

   event.respondWith(cacheApiRequest(event.request))
})

async function cacheApiRequest(request) {
   const cache = await caches.open(API_CACHE);
   const cachedResponse = await cache.match(request);
   const fetchPromise = fetch(request).then(async (networkResponse) => {
      cache.put(request, networkResponse.clone());
      return networkResponse;
   }).catch(() => cachedResponse);
   return cachedResponse || fetchPromise;
}