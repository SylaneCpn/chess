'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "b6d15db83941c7117705e38217114739",
"assets/AssetManifest.bin.json": "bc863b2efbadfcc89f5a4c73f08af914",
"assets/assets/pieces-svg/amazon-b.svg": "fdc855c812241206f3b3d26ea8e7793b",
"assets/assets/pieces-svg/amazon-w.svg": "4f94274ed802057275a51f8aeb6d35d2",
"assets/assets/pieces-svg/archbis-b.svg": "f24a17ad51a26d371f54f2fe7af952f3",
"assets/assets/pieces-svg/archbis-w.svg": "d2ceda06a2075ab8bacea1e550b50822",
"assets/assets/pieces-svg/augna-b.svg": "8f368cdcfb24ee8af1f6c8ba42207b2d",
"assets/assets/pieces-svg/augna-w.svg": "882aa579a6052305ef97a335a978338f",
"assets/assets/pieces-svg/augnd-b.svg": "9dced822902eb9012aca55d80fc09d67",
"assets/assets/pieces-svg/augnd-w.svg": "6274526b554f71ed562ea87a1eeed7f8",
"assets/assets/pieces-svg/augnf-b.svg": "753dece6d64995c0c2ca1ac2faa601b6",
"assets/assets/pieces-svg/augnf-w.svg": "d6e540e9503af9111ff6481e78da5edc",
"assets/assets/pieces-svg/augnw-b.svg": "8fb19d8fc5b3af760299349e16c98037",
"assets/assets/pieces-svg/augnw-w.svg": "67b60f5a34efdad7137406a5a167931f",
"assets/assets/pieces-svg/bishop-b.svg": "07084ebfb3049865579b2bad3135fe38",
"assets/assets/pieces-svg/bishop-w.svg": "a685d8c21f02be9f1166b3facb6f604f",
"assets/assets/pieces-svg/bpawn-b.svg": "98d13cbb9d620d19778800818c7a1a1c",
"assets/assets/pieces-svg/bpawn-w.svg": "179653d0d43fa9133c94e6424d96f292",
"assets/assets/pieces-svg/bpawn2-b.svg": "bb290bbd8e7e0d6076f6774973c2b534",
"assets/assets/pieces-svg/bpawn2-w.svg": "83319fbe477e140948a5cdbf02032cd7",
"assets/assets/pieces-svg/centaur-b.svg": "e9fe1dce2c8be515e86a89e0db702ab7",
"assets/assets/pieces-svg/centaur-w.svg": "e945940ba9c5654cc53e1548393f7ce6",
"assets/assets/pieces-svg/chancel-b.svg": "36a1fb3b2a2985af328607ebbed2fb76",
"assets/assets/pieces-svg/chancel-w.svg": "620180de7752171b6ed1bda61bf11b9c",
"assets/assets/pieces-svg/commonr-b.svg": "8caed13c7cd8a31576b9a1dddbaf909c",
"assets/assets/pieces-svg/commonr-w.svg": "162d74eac0f6217da31ad4f77dc761b0",
"assets/assets/pieces-svg/grassh-b.svg": "55498fe92b3dc5484c6be59be7f21932",
"assets/assets/pieces-svg/grassh-w.svg": "f9a47034b6ae6e41b655af007529b906",
"assets/assets/pieces-svg/king-b.svg": "71625b854ec0134dec696399bcecbf50",
"assets/assets/pieces-svg/king-w.svg": "14b1b80e586b180df094ca6c29a80bf0",
"assets/assets/pieces-svg/knight-b.svg": "eb2b3bfe2217afe43a522604801ac412",
"assets/assets/pieces-svg/knight-w.svg": "90350db4eee63055fd06e3e596b6ad23",
"assets/assets/pieces-svg/nightrd-b.svg": "29942d77324927229f5f88312949a858",
"assets/assets/pieces-svg/nightrd-w.svg": "c4dac721f1c894b6503a686c6bf32306",
"assets/assets/pieces-svg/nrking-b.svg": "b4c8b30969ca3dd0f724b101205cc863",
"assets/assets/pieces-svg/nrking-w.svg": "dba45f511a00c14d9d5485d925677a31",
"assets/assets/pieces-svg/pawn-b.svg": "d928d4b286f82fad5a9e36e9a65b275f",
"assets/assets/pieces-svg/pawn-w.svg": "ddafa03e9e32cd6a73345a583d1840f8",
"assets/assets/pieces-svg/queen-b.svg": "a2c91352b003d3c9f4e7b3956ba8c5f3",
"assets/assets/pieces-svg/queen-w.svg": "d0bb4a02829a691de759ba0c6ec20087",
"assets/assets/pieces-svg/rknight-b.svg": "cc8e66c26e4b1a216eeb93f44d25548a",
"assets/assets/pieces-svg/rknight-w.svg": "269b0d2912d9b0e650361979b7b9adc3",
"assets/assets/pieces-svg/rook-b.svg": "4ec62f9f70107df736bd927d52f5e566",
"assets/assets/pieces-svg/rook-w.svg": "4889128413f1867e4c4f4466da4650a2",
"assets/assets/pieces-svg/rook4-b.svg": "8ea84ec1b1a4bdad12f982501831d06c",
"assets/assets/pieces-svg/rook4-w.svg": "1354e72e6003fb84cde4ffc3190528c6",
"assets/assets/pieces-svg/rqueen-b.svg": "c03ee28c955831c6a14cdb4029da015b",
"assets/assets/pieces-svg/rqueen-w.svg": "36d59d4559ff089a6e2712979c2ca3d9",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "c0ad29d56cfe3890223c02da3c6e0448",
"assets/NOTICES": "1030a71128dc52c3af874339e682b4f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "11dd266b091ecd9fdf6f7d8dee2f9d04",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "cb001c8f3502eefa8c391dbd99516422",
"icons/Icon-192.png": "4c90127194ef5ca09f6f1e4cee1a5e5b",
"icons/Icon-512.png": "1c0de87112004c1f1c488c2de2a63fdb",
"icons/Icon-maskable-192.png": "4c90127194ef5ca09f6f1e4cee1a5e5b",
"icons/Icon-maskable-512.png": "1c0de87112004c1f1c488c2de2a63fdb",
"index.html": "83acf58afde9b8af6214e9094cd2a744",
"/": "83acf58afde9b8af6214e9094cd2a744",
"main.dart.js": "e204c720b7fd3249881b6cd6f1649931",
"main.dart.mjs": "8857471d3df523e105e42a1c7b526363",
"main.dart.wasm": "cf698959d7ceca04240aec8d48876870",
"manifest.json": "ce4bd370e07b4fb09b643e36a63ce534",
"version.json": "ed4643e737ed82fb5c59c656cc118bb5"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"main.dart.wasm",
"main.dart.mjs",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
