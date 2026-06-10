self.addEventListener("fetch", function(event) {
  // Only handle GET requests
  if (event.request.method !== "GET") {
    return;
  }

  const url = new URL(event.request.url);

  // Only handle http/https schemes (avoid chrome-extension://, etc.)
  if (url.protocol !== "http:" && url.protocol !== "https:") {
    return;
  }

  // Bypass API requests
  if (url.pathname.startsWith("/api/")) {
    return;
  }

  // NÃO FAZER CACHE DE HTML
  if (event.request.headers.get("accept")?.includes("text/html")) {
    return;
  }

  // CACHE PARA OUTROS ARQUIVOS (JS, CSS, IMAGENS)
  event.respondWith(
    caches.open("imoviu-cache-v1").then(function(cache) {
      return cache.match(event.request).then(function(response) {
        return (
          response ||
          fetch(event.request).then(function(networkResponse) {
            // Only cache successful standard responses
            if (networkResponse.status === 200 && networkResponse.type === "basic") {
              cache.put(event.request, networkResponse.clone());
            }
            return networkResponse;
          }).catch(function() {
            return response;
          })
        );
      });
    })
  );
});