# Database Girone I — stato del progetto

Documento di passaggio di consegne: cosa è il progetto, come è fatto, cosa è stato deciso, dove siamo arrivati. Va aggiornato a ogni modifica importante. Ultimo aggiornamento: 7 novembre 2026.

## 1. Cos'è

Banca dati privata sui giocatori delle **5 squadre calabresi della Serie D 2026/27, girone I**: Reggina, Vigor Lamezia, Sambiase, Vibonese, Digiesse Praia Tortora. In tutto 150 partite che le riguardano.

Obiettivi:
- raccogliere dati evento per evento, partita per partita, con una pulsantiera da telefono o iPad mentre si guarda il video;
- confrontare ogni giocatore con la media del ruolo e del girone, con valori ogni 90', filtri e percentili, nello stile di Wyscout e Hudl;
- vendere i dati a procuratori e agenzie, e in prospettiva ai club. Ai club si può proporre: a ognuno i propri dati, e il proprietario conserva il diritto di usarli.

Il proprietario è un ex match analyst della Vigor Lamezia in Eccellenza. Lavora con alcuni soci: ognuno segue una squadra e tutti usano le stesse regole di rilevazione.

## 2. Dove sta

| Cosa | Dove |
|---|---|
| Sito / app | https://erregi37.github.io/db-girone-i/ (GitHub Pages, ramo `main`, cartella principale) |
| Codice | https://github.com/erregi37/db-girone-i (pubblico: solo codice, nessun dato) |
| Database e login | Supabase, progetto `https://jivrnlvcfovistersklv.supabase.co`, regione EU |
| Chiave nel codice | `sb_publishable_…`: è pubblica per costruzione. La `service_role` / secret non va mai condivisa né messa nel codice |

Chi modifica il codice: il proprietario (con GitHub Desktop), Claude (connettore GitHub con permesso di scrittura sul solo repository) e ChatGPT (connettore GitHub). Regole di lavoro in `AGENTS.md` / `CLAUDE.md`.

La vecchia versione era un artifact su claude.ai, "Database Girone I". Non va più usata: i dati sono stati trasferiti su Supabase il 5 novembre 2026.

## 3. Com'è fatta

- **Un solo file**, `index.html`, contiene HTML, CSS e JavaScript. Niente build. Librerie da CDN con versione fissa: SheetJS 0.18.5 e supabase-js 2.118.0.
- **App installabile** sul telefono: `manifest.webmanifest`, icone in `assets/` (logo Serie D) e `sw.js`. Il service worker è minimo: non salva copie delle pagine, serve solo a rendere l'app installabile con un tocco su Android e a mostrare "Sei offline". Gli aggiornamenti del codice arrivano da soli alla riapertura dell'app.
- **Database**: una tabella `docs (coll, id, data jsonb)`. In fondo a `index.html`, `makeDb()` imita l'interfaccia di Firestore (`collection().onSnapshot`, `doc().set/update/delete/get`) con aggiornamenti in tempo reale. Collezioni: `players`, `calendario`, `sessions`, `sessidx`, `matches`, `allenatori`, `stemmi`, `glossario`.
- **Accessi**: email e password. Chi si registra resta "in attesa"; l'admin assegna lettore, editor o admin dal tab Accessi. I permessi sono applicati dal database (RLS) in `supabase/schema.sql`. Il primo account registrato è diventato admin.
- **Backup**: dal tab Accessi, "Scarica backup completo" (JSON) e "Importa da file". I backup non vanno mai messi nel repository.

### Pagine (tab)

1. **Ricerca**: filtri per squadra, ruolo, "più utilizzato come" e minuti minimi; indicatori scelti ogni 90'. Sul telefono i risultati sono schede, con verde/rosso rispetto alla media del ruolo.
2. **Giornate**: calendario delle calabresi, risultati, marcatori, allenatore, stato della rilevazione per squadra, pulsanti "Analizza ora" e "Riprendi". Toccando una calabrese si apre la sua rosa.
3. **Rilevazione**: elenco delle sessioni e pulsantiera (dettagli nella sezione 4).
4. **Rete passaggi**: nodi dimensionati sui passaggi ricevuti, archi sulla frequenza; distingue passaggi in avanti, orizzontali e all'indietro.
5. **Carica partite**: import da Excel.
6. **Rose**: solo le 5 calabresi. Ordinamento per numero, cognome, ruolo, più utilizzato, anno, piede, presenze, minuti, % minuti, gol e assist. I ceduti restano in fondo, in grigio, con "ceduto · ora X". Le statistiche della rosa contano solo quanto fatto con quella squadra. In alto il conteggio degli under per fascia; c'è anche il Report Excel. Sul telefono la rosa è a schede.
7. **Glossario**: definizioni degli indicatori.
8. **Accessi** (solo admin): approvazione dei soci e backup.

Ci sono anche il tema chiaro/scuro, il pulsante "Installa app" e la scheda giocatore con: anagrafica (nome modificabile, anno, ruolo, posizione naturale, squadra, numero per ogni squadra, piede), valutazione dell'osservatore, dati ogni 90' a confronto, posizioni (partite per posizione, e toccando i moduli), rigori, partita per partita.

## 4. Pulsantiera di rilevazione

- **Telefono**: lo schieramento si fa in verticale; la pulsantiera solo in orizzontale (in verticale compare "Gira il telefono"). Sull'iPad vanno bene entrambi i versi.
- **Schieramento**:
  - modulo e pallini; si inizia solo con 11 giocatori;
  - toccando un pallino si vedono prima i giocatori adatti a quella posizione, poi gli altri, per numero di maglia, con barra di ricerca per nome o numero;
  - panchina e numeri di maglia della singola partita, con i numeri ripetuti in rosso;
  - etichette under sui pallini.
- **Trascinamento**: un pallino su un altro = scambio (nello schieramento cambia la formazione, durante la partita registra un cambio di ruolo); la panchina è sempre visibile sotto il campo e un panchinaro trascinato su un pallino entra (nello schieramento) o fa il cambio (in partita); nello schieramento un pallino trascinato sulla panchina torna in panchina.
- **Eventi** (`EVB`): passaggio (giocatore → giocatore), X = passaggio sbagliato, KP (key pass = passaggio fatto nella trequarti offensiva), ↑AV / ↓IN, PP, cross ±, dribbling ±, FS, tiri (TIP, TIF, TIM), GOL, GOLR, duelli difensivi ±, aerei ±, contrasto, intercetto, fallo commesso, giallo, parata, uscita, GS.
- **Tiri e xG**:
  - si apre il mezzo campo e si tocca il punto del tiro;
  - poi parte del corpo (destro, sinistro, testa, altro), situazione (azione, contropiede, palla inattiva, punizione diretta, rigore) e "solo davanti al portiere";
  - "Senza posizione" registra il tiro senza xG.
- **Rigori**:
  - si apre la porta vista da chi calcia e si tocca dove è andato il pallone (anche fuori dallo specchio);
  - si salvano lato, altezza, aperto/incrociato/centrale (in base al piede) e punteggio al momento;
  - lo storico è nel profilo.
- **Barra in alto**: ⇄ Campo (gira il campo come in TV; si gira da solo all'Intervallo), Intervallo (fine 1° tempo e recupero), Segnalibro, Registro (eventi modificabili ed eliminabili), Fine (recupero 2° tempo, Esporta Excel, Invia alla piattaforma).
- **Accanto al campo**: Annulla, Cambio, Ruolo (scambio di posizione), Modulo, Rosso, Gol subito; poi gli eventi a coppie ✓/✗ su 4 colonne: Passaggio, Giocata, Possesso e falli, Tiro, Difesa, Recuperi e portiere. Il gol su rigore si registra con Gol → situazione Rigore.
- **Controllo under** nella barra: ✓/✗ per 08, 07 e 06.
- **Salvataggio** continuo nel database, più una copia nel browser.

## 5. Regole e decisioni prese

- **Minuti dell'evento**: non si registrano. Si stimano dalla posizione nel registro. Il minuto si scrive a mano solo se serve, per esempio su un cambio, anche nella forma "45+2" o "90+3".
- **Minuti reali**: durata = 90 + recupero 1° tempo + recupero 2° tempo. Servono per i p90 e la % minuti, che è calcolata sul totale dei minuti della squadra.
- **Presenze**: contano già dallo schieramento iniziale, anche prima dell'invio. Chi entra da un cambio prende presenza e subentro: si scrive 10 (3).
- **Posizioni**:
  - `POSBYROLE` fa da mappa;
  - **Difensori**: centrale destro e sinistro nella difesa a 4; braccetto destro, centrale e braccetto sinistro nella difesa a 3;
  - **Centrocampisti**: il regista si chiama **Play**; poi mediano, mezzala, centrocampista (a due);
  - **Esterni**: il quinto è un'unica posizione (quinto destro / sinistro), nella famiglia degli esterni;
  - **"Più utilizzato"** è la posizione in cui il giocatore è stato schierato più volte; la "posizione naturale" della scheda vale solo finché non ha partite.
- **Under (regola Serie D 2026/27, indicata dal proprietario e da verificare sul comunicato LND)**: sempre in campo almeno un 2008 o più giovane, un 2007 e un 2006, tre giocatori diversi. Costante `UNDER` da aggiornare ogni stagione.
- **xG**:
  - base: modello logistico di Soccermatics (Premier League 2017/18, distanza e angolo);
  - correzioni stimate, non tarate sulla Serie D: testa −1,0 sul logit, altro −0,6, contropiede +0,35, palla inattiva −0,2, punizione diretta −0,25, solo davanti al portiere +1,0;
  - rigore = 0,79;
  - il valore non viene salvato ma ricalcolato, quindi il modello si potrà ritarare con qualche centinaio di tiri di Serie D.
- **Trasferimenti**: `squadra` è quella attuale (anche fuori girone, testo libero) e `ex` le precedenti. I numeri di maglia valgono per squadra (`numeri`). Esempio: Sabella, ex Vigor (numero 22), ora Vibonese.
- **Risultati**: non si modificano a mano.
- **Nessun dato nel repository**, perché è pubblico.

## 6. Dati presenti (al 7 novembre 2026)

- 138 giocatori importati (più quelli aggiunti dopo dal proprietario), 150 partite in calendario, risultati fino alla giornata 10, marcatori per 34 partite;
- 4 rilevazioni di prova;
- gli stemmi sono stati caricati dal proprietario; i pulsanti di caricamento sono stati poi tolti.

## 7. Cose aperte

- **Aggiornamento automatico dei risultati** (era un'attività programmata ogni domenica alle 19): scrive ancora nella vecchia versione su Claude, non in Supabase. Per scrivere su Supabase da un'attività automatica serve una soluzione sicura, senza esporre la chiave segreta. Da fare. Nel frattempo l'attività vecchia andrebbe disattivata.
- **Marcatori mancanti**: tutta la giornata 1, tre partite della giornata 4, il recupero Castrumfavara–Reggina.
- **Numeri di maglia**: manca il numero di Sabella alla Vibonese; la Digiesse Praia Tortora non ha numeri.
- **Correzioni di nomi**: il numero 11 del Sambiase è Giancarlo **Simigliani**; lo corregge il proprietario dalla scheda. I doppi cognomi sudamericani sono ordinati per l'ultimo cognome: da confermare.
- **Verifiche fatte solo in simulazione** (database finto e telefono emulato): tempo reale tra dispositivi, installazione con un tocco su Android.
- **Idee non ancora fatte**: rigori calciati e segnati come colonna nelle statistiche; mappa dei tiri nel profilo; posizione separata per squadra (scartata per ora).

## 8. Come lavorare (per Claude, ChatGPT o chiunque)

1. Prima di modificare: `git pull`. Una modifica alla volta, commit in italiano, push subito.
2. Il proprietario vuole: **una sola proposta migliore** invece di tante opzioni; testi in italiano; onestà sui limiti ("non posso verificarlo" piuttosto che inventare); niente gergo tecnico nelle risposte.
3. Il sito va pensato **prima per il telefono in verticale**.
4. Cambi alla struttura dei dati o allo schema SQL vanno spiegati al proprietario. Lo schema si riesegue a mano nel SQL Editor di Supabase.
5. Per provare senza toccare i dati veri si usa un Supabase finto (oggetto `window.supabase` simulato) con Playwright; i dati iniziali stanno in un backup JSON, mai nel repository.
6. Dopo ogni modifica pubblicata, al proprietario basta ricaricare la pagina o riaprire l'app.
