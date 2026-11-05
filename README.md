# Database Girone I

Banca dati privata sui giocatori delle squadre calabresi della Serie D 2026/27, girone I: rose, calendario, rilevazione degli eventi partita per partita (pulsantiera da telefono/iPad), statistiche ogni 90', rete dei passaggi.

- **Sito:** https://erregi37.github.io/db-girone-i/ (serve un account approvato)
- **Dati:** su Supabase, protetti da login. In questo repository c'è solo il codice: nessun dato.

## File

| File | Cosa contiene |
|---|---|
| `index.html` | Tutta l'app: pagina, stile e codice in un solo file |
| `supabase/schema.sql` | Tabelle e regole di accesso del database (si esegue una volta nel SQL Editor di Supabase) |
| `AGENTS.md` | Istruzioni per chi modifica il codice (persone, Claude, ChatGPT) |

## Permessi

Chi si registra resta «in attesa» finché l'admin non gli assegna un permesso dal tab **Accessi**: lettore (consulta), editor (consulta e modifica), admin (anche accessi e backup).

## Backup

Dal tab **Accessi** → *Scarica backup completo*. Lo stesso file si reimporta con *Importa da file*. I backup non vanno mai caricati in questo repository: è pubblico.
