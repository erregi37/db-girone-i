/* Service worker minimo: rende l'app installabile e mostra un avviso se manca la connessione.
   Non salva copie delle pagine, così gli aggiornamenti arrivano sempre subito. */
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", e => e.waitUntil(self.clients.claim()));
self.addEventListener("fetch", e => {
  if (e.request.mode !== "navigate") return;
  e.respondWith(fetch(e.request).catch(() => new Response(
    '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Database Girone I</title><body style="font-family:system-ui;background:#060B16;color:#E4ECF8;display:grid;place-items:center;min-height:100vh;margin:0;padding:24px;text-align:center"><div><h2>Sei offline</h2><p>Serve la connessione per aprire il database. Riprova quando torna la rete.</p><button onclick="location.reload()" style="font:inherit;padding:10px 18px;border-radius:8px;border:0;background:#3CCBF4;color:#06121f">Riprova</button></div></body>',
    { headers: { "Content-Type": "text/html; charset=utf-8" } })));
});
