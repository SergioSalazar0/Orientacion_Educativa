-- ============================================================
-- storage.sql  — Buckets y políticas de Storage
-- Ejecutar DESPUÉS de rls.sql
-- ============================================================

-- ── Crear buckets privados ────────────────────────────────────────────────
insert into storage.buckets (id, name, public)
values
  ('student-photos',       'student-photos',       false),
  ('report-images',        'report-images',        false),
  ('justification-files',  'justification-files',  false),
  ('avatars',              'avatars',              false)
on conflict (id) do nothing;

-- ═══════════════════════════════════════════════════════════════
-- student-photos
-- ═══════════════════════════════════════════════════════════════
create policy "student-photos: orientador all"
  on storage.objects for all
  using (bucket_id = 'student-photos' and is_orientador())
  with check (bucket_id = 'student-photos' and is_orientador());

create policy "student-photos: padre select"
  on storage.objects for select
  using (
    bucket_id = 'student-photos'
    and is_parent_of((storage.foldername(name))[1]::uuid)
  );

-- ═══════════════════════════════════════════════════════════════
-- report-images
-- ═══════════════════════════════════════════════════════════════
create policy "report-images: orientador all"
  on storage.objects for all
  using (bucket_id = 'report-images' and is_orientador())
  with check (bucket_id = 'report-images' and is_orientador());

create policy "report-images: padre select"
  on storage.objects for select
  using (
    bucket_id = 'report-images'
    and is_parent_of((storage.foldername(name))[1]::uuid)
  );

-- ═══════════════════════════════════════════════════════════════
-- justification-files
-- ═══════════════════════════════════════════════════════════════
create policy "justification-files: orientador all"
  on storage.objects for all
  using (bucket_id = 'justification-files' and is_orientador())
  with check (bucket_id = 'justification-files' and is_orientador());

create policy "justification-files: padre select"
  on storage.objects for select
  using (
    bucket_id = 'justification-files'
    and is_parent_of((storage.foldername(name))[1]::uuid)
  );

-- ═══════════════════════════════════════════════════════════════
-- avatars — cada usuario gestiona su propio avatar
-- ═══════════════════════════════════════════════════════════════
create policy "avatars: select own"
  on storage.objects for select
  using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "avatars: insert own"
  on storage.objects for insert
  with check (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "avatars: update own"
  on storage.objects for update
  using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "avatars: delete own"
  on storage.objects for delete
  using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

-- Orientador puede ver todos los avatares
create policy "avatars: orientador select all"
  on storage.objects for select
  using (bucket_id = 'avatars' and is_orientador());
