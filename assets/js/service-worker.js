importScripts('https://storage.googleapis.com/workbox-cdn/releases/4.3.1/workbox-sw.js');

// Force production builds
// (comment this line out for lotsa extra logging)
workbox.setConfig({ debug: false });

// Cache CSS and JavaScript
workbox.routing.registerRoute(
  /\.(?:css|js)$/,
  new workbox.strategies.CacheFirst({
    cacheName: 'assets',
    plugins: [
      new workbox.expiration.Plugin({
        maxAgeSeconds: 24 * 60 * 60, // 1 Day
        // Automatically cleanup if quota is exceeded.
        purgeOnQuotaError: true,
      })
    ]
  })
);

// Cache non-opaque images (served from my site)
workbox.routing.registerRoute(
  /\.(?:png|gif|jpg|jpeg|webp|svg|ico)/,
  new workbox.strategies.CacheFirst({
    cacheName: 'images',
    plugins: [
      new workbox.expiration.Plugin({
        maxEntries: 60,
        maxAgeSeconds: 7 * 24 * 60 * 60, // 1 week
        // Automatically cleanup if quota is exceeded.
        purgeOnQuotaError: true,
      }),
    ],
  })
);

// Cache "opaque" apple music album cover images
// https://developers.google.com/web/tools/workbox/guides/handle-third-party-requests
workbox.routing.registerRoute(
  /.*ssl\.mzstatic\.com\/image\/thumb\/Music123\//,
  new workbox.strategies.CacheFirst({
    cacheName: 'album-covers',
    plugins: [
      // this is required to cache an "opaque" asset
      new workbox.cacheableResponse.Plugin({
        statuses: [0, 200]
      }),
      new workbox.expiration.Plugin({
        maxEntries: 60,
        maxAgeSeconds: 7 * 24 * 60 * 60, // 1 week
        // Automatically cleanup if quota is exceeded.
        purgeOnQuotaError: true,
      }),
    ],
  })
);

// Basic PWA viewing functionality offline
['/', '/lists'].forEach(route => {
  workbox.routing.registerRoute(
    route,
    new workbox.strategies.NetworkFirst({
        networkTimeoutSeconds: 3,
        cacheName: 'album-tags-pwa',
        plugins: [
          new workbox.expiration.Plugin({
            // maxEntries: 50,
            maxAgeSeconds: 24 * 60 * 60, // 1 day
            // Automatically cleanup if quota is exceeded.
            purgeOnQuotaError: true,
          }),
        ],
    })
  );
});

// Basic PWA viewing functionality for lists and albums pages offline
workbox.routing.registerRoute(
  /.*\/(?:lists|albums)\/[0-9]*$/,
  new workbox.strategies.NetworkFirst({
      networkTimeoutSeconds: 3,
      cacheName: 'album-tags-pwa',
      plugins: [
        new workbox.expiration.Plugin({
          // maxEntries: 50,
          maxAgeSeconds: 24 * 60 * 60, // 1 day
          // Automatically cleanup if quota is exceeded.
          purgeOnQuotaError: true,
        }),
      ],
  })
);

// Cache the Google Fonts stylesheets with a stale-while-revalidate strategy.
workbox.routing.registerRoute(
  /^https:\/\/fonts\.googleapis\.com/,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: 'google-fonts-stylesheets',
  })
);

// Cache the underlying font files with a cache-first strategy for 1 year.
workbox.routing.registerRoute(
  /^https:\/\/fonts\.gstatic\.com/,
  new workbox.strategies.CacheFirst({
    cacheName: 'google-fonts-webfonts',
    plugins: [
      new workbox.cacheableResponse.Plugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.Plugin({
        maxAgeSeconds: 60 * 60 * 24 * 365, // 1 year
        maxEntries: 30,
        // Automatically cleanup if quota is exceeded.
        purgeOnQuotaError: true,
      }),
    ],
  })
);
