-- Database Girone I: schema per Supabase.
-- Si incolla una sola volta nel SQL Editor di Supabase e si preme Run.
-- Si può rieseguire senza danni: usa "if not exists" / "or replace".

-- 1. Tutti i dati dell'app stanno in una tabella: collezione + id + contenuto JSON
create table if not exists public.docs (
  coll       text        not null,
  id         text        not null,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (coll, id)
);

-- 2. Chi ha un account e che permessi ha.
--    attesa = registrato ma non ancora approvato (non vede nulla)
--    lettore = vede i dati, non modifica
--    editor = vede e modifica
--    admin = come editor, più approva gli accessi e fa i backup
create table if not exists public.profili (
  id     uuid primary key references auth.users(id) on delete cascade,
  email  text,
  ruolo  text not null default 'attesa' check (ruolo in ('attesa','lettore','editor','admin')),
  creato timestamptz not null default now()
);

-- 3. Alla registrazione crea il profilo. Il PRIMO account in assoluto diventa admin.
create or replace function public.nuovo_utente() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profili (id, email, ruolo)
  values (
    new.id,
    new.email,
    case when exists (select 1 from public.profili where ruolo = 'admin') then 'attesa' else 'admin' end
  );
  return new;
end $$;

drop trigger if exists alla_registrazione on auth.users;
create trigger alla_registrazione after insert on auth.users
  for each row execute function public.nuovo_utente();

-- 4. Ruolo dell'utente collegato (security definer: evita giri ricorsivi nelle regole)
create or replace function public.mio_ruolo() returns text
language sql stable security definer set search_path = public as $$
  select ruolo from public.profili where id = auth.uid()
$$;

-- 5. Unisce campi a un documento esistente (come "update" di prima), in modo atomico
create or replace function public.unisci_doc(p_coll text, p_id text, p_patch jsonb) returns void
language sql security invoker set search_path = public as $$
  insert into public.docs (coll, id, data) values (p_coll, p_id, p_patch)
  on conflict (coll, id) do update set data = public.docs.data || excluded.data, updated_at = now()
$$;

-- 6. Regole di accesso (RLS): senza login non si vede niente
alter table public.docs    enable row level security;
alter table public.profili enable row level security;

drop policy if exists docs_lettura  on public.docs;
drop policy if exists docs_scrittura on public.docs;
drop policy if exists docs_modifica on public.docs;
drop policy if exists docs_cancella on public.docs;
create policy docs_lettura  on public.docs for select to authenticated
  using (public.mio_ruolo() in ('lettore','editor','admin'));
create policy docs_scrittura on public.docs for insert to authenticated
  with check (public.mio_ruolo() in ('editor','admin'));
create policy docs_modifica on public.docs for update to authenticated
  using (public.mio_ruolo() in ('editor','admin')) with check (public.mio_ruolo() in ('editor','admin'));
create policy docs_cancella on public.docs for delete to authenticated
  using (public.mio_ruolo() in ('editor','admin'));

drop policy if exists profili_proprio on public.profili;
drop policy if exists profili_admin_modifica on public.profili;
create policy profili_proprio on public.profili for select to authenticated
  using (id = auth.uid() or public.mio_ruolo() = 'admin');
create policy profili_admin_modifica on public.profili for update to authenticated
  using (public.mio_ruolo() = 'admin') with check (public.mio_ruolo() = 'admin');

-- 7. Permessi sulle tabelle: chi non è loggato (anon) non può toccare nulla
revoke all on public.docs, public.profili from anon;
grant select, insert, update, delete on public.docs to authenticated;
grant select, update on public.profili to authenticated;
revoke all on function public.unisci_doc(text, text, jsonb) from public, anon;
grant execute on function public.unisci_doc(text, text, jsonb) to authenticated;
revoke all on function public.mio_ruolo() from public, anon;
grant execute on function public.mio_ruolo() to authenticated;

-- 8. Aggiornamenti in tempo reale tra telefono, iPad e PC
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'docs') then
    alter publication supabase_realtime add table public.docs;
  end if;
end $$;
