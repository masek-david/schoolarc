const { generateSW } = require('workbox-build');

generateSW({
  globDirectory: 'build/web/',
  globPatterns: ['**/*.{json,otf,ttf,js,wasm,png,html,css,md,svg,yaml,frag}'],
  globIgnores: ['canvaskit/**',
    'awesome_notifications/**',
    'generate_service_worker.js',
  ],
  swDest: 'build/web/service-worker.js',
  maximumFileSizeToCacheInBytes: 10000000,
  // for ios to disk cache gstatic files
  runtimeCaching: [
    {
      urlPattern: ({ url }) => url.hostname.includes('gstatic.com'),
      handler: 'CacheFirst',
      options: {
        cacheName: 'gstatic-cache',
        expiration: {
          maxAgeSeconds: 60 * 60 * 24 * 365,
        },
        cacheableResponse: {
          statuses: [0, 200],
        },
      },
    },
  ],
}).then(({ count, size, warnings }) => {
  if (warnings.length > 0) {
    console.warn(
      'Warnings encountered while generating a service worker:',
      warnings.join('\n')
    );
  }

  console.log(`Generated a service worker, which will precache ${count} files, totaling ${size} bytes.`);
});