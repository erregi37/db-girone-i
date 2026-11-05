# Istruzioni per chi modifica questo progetto

Vale per persone, Claude, ChatGPT e qualsiasi altro assistente.

## Regole
1. **Una modifica alla volta.** Prima di iniziare, scarica l'ultima versione (pull). Dopo, fai commit con un messaggio chiaro in italiano e push subito.
2. **Nessun dato nel repository.** Il repository è pubblico. Mai committare backup, file JSON di dati, rose, rilevazioni, email o chiavi segrete. La chiave `sb_publishable_...` in `index.html` è pubblica per progettazione; la `service_role`/secret key non deve mai comparire.
3. **Un solo file per l'app.** `index.html` contiene HTML, CSS e JavaScript. Niente build, niente framework: deve funzionare aperto così com'è da GitHub Pages.
4. **Non cambiare la struttura dei dati senza dirlo.** Il database è una tabella `docs (coll, id, data jsonb)`. Collezioni in uso: `players`, `calendario`, `sessions`, `sessidx`, `matches`, `allenatori`, `stemmi`, `glossario`. Rinominare campi rompe i dati già salvati.
5. **Modifiche allo schema** vanno in `supabase/schema.sql` (rieseguibile) e vanno segnalate al proprietario, che deve rieseguirlo nel SQL Editor di Supabase.
6. Testi dell'interfaccia in italiano.

## Come funziona il codice
- In fondo a `index.html`, `makeDb()` offre al resto della pagina un'interfaccia tipo Firestore (`db.collection(c).onSnapshot`, `db.doc("coll/id").set/update/delete/get/onSnapshot`) sopra la tabella `docs`, con aggiornamenti in tempo reale via Supabase Realtime.
- Accesso: email e password (Supabase Auth). Permessi nella tabella `profili` (`attesa`, `lettore`, `editor`, `admin`), applicati dal database con RLS, non solo dall'interfaccia.
- Ruolo e posizione: `ruolo` (POR, DC, TER, CEN, EST, TRQ, ATT) è la famiglia; `posizione` (es. TD, TS, QD, MEZ, CC, SP) è il posto preciso, scelto nella scheda o, se vuoto, quello con più minuti negli schieramenti (`posOf`). Mappa in `POSBYROLE`. Il quinto (QD/QS) è un'unica posizione, nella famiglia Esterni.
- xG: `xgOf(e)` calcola l'xG di ogni tiro dai campi salvati sull'evento (`x` 0–68 larghezza, `d` 0–52,5 metri dalla linea di porta, `bp` parte del corpo, `sit` situazione, `oo` solo davanti al portiere). Il valore non viene salvato: si ricalcola, quindi il modello si può ritoccare senza perdere dati. Rigore = 0,79.
- Presenze: `writeIdx` salva in `sessidx/<id>.pres` chi è stato schierato o è entrato, con la posizione; `aggregate` le conta finché la partita non è inviata.
- Under: `UNDER=[2008,2007,2006]` (regola Serie D 2026/27); `underCheck` verifica che in campo ci sia un giocatore diverso per ogni fascia. Da aggiornare a ogni stagione.
- Rilevazione: ogni sessione è un documento `sessions/<id>` con il registro degli eventi (`log`); le statistiche si ricalcolano dal registro (`replay`, `computeSess`).
- Librerie da CDN con versione fissa: SheetJS 0.18.5, supabase-js 2.118.0.
