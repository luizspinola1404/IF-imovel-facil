self.addEventListener("fetch", function(event) {

  // NÃO FAZER CACHE DE HTML
  if (event.request.headers.get("accept")?.includes("text/html")) {
    event.respondWith(fetch(event.request));
    return;
  }

  // CACHE PARA OUTROS ARQUIVOS (JS, CSS, IMAGENS)
  event.respondWith(
    caches.open("imoviu-cache-v1").then(function(cache) {
      return cache.match(event.request).then(function(response) {
        return (
          response ||
          fetch(event.request).then(function(networkResponse) {
            cache.put(event.request, networkResponse.clone());
            return networkResponse;
          })
        );
      });
    })
  );

});