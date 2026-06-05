-- ============================================================
-- rls.sql  — Row Level Security
-- Ejecutar DESPUÉS de schema.sql
-- ============================================================

-- ── Helper: ¿el usuario actual es orientador? ─────────────────────────────
create or replace function is_orientador()
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from profiles
    where id = auth.uid() and role = 'orientador'
  );
$$;

-- ── Helper: ¿el usuario actual es padre de este alumno? ───────────────────
create or replace function is_parent_of(p_student_id uuid)
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from parent_students
    where parent_id = auth.uid() and student_id = p_student_id
  );
$$;

-- ═══════════════════════════════════════════════════════════════
-- profiles
-- ═══════════════════════════════════════════════════════════════
alter table profiles enable row level security;

-- Cada usuario lee y actualiza su propio perfil
create policy "profiles: select own"
  on profiles for select
  using (id = auth.uid() or is_orientador());

create policy "profiles: update own"
  on profiles for update
  using (id = auth.uid());

-- El trigger handle_new_user necesita insertar (usa security definer)
create policy "profiles: insert via trigger"
  on profiles for insert
  with check (id = auth.uid());

-- ═══════════════════════════════════════════════════════════════
-- students
-- ═══════════════════════════════════════════════════════════════
alter table students enable row level security;

create policy "students: orientador full access"
  on students for all
  using (is_orientador())
  with check (is_orientador());

create policy "students: padre select own child"
  on students for select
  using (is_parent_of(id));

-- ═══════════════════════════════════════════════════════════════
-- guardians
-- ═══════════════════════════════════════════════════════════════
alter table guardians enable row level security;

create policy "guardians: orientador full access"
  on guardians for all
  using (is_orientador())
  with check (is_orientador());

create policy "guardians: padre select own child"
  on guardians for select
  using (is_parent_of(student_id));

-- ═══════════════════════════════════════════════════════════════
-- parent_students
-- ═══════════════════════════════════════════════════════════════
alter table parent_students enable row level security;

create policy "parent_students: orientador full access"
  on parent_students for all
  using (is_orientador())
  with check (is_orientador());

create policy "parent_students: padre select own"
  on parent_students for select
  using (parent_id = auth.uid());

-- Permitir la inserción vía redeem_invitation_code (que usa security definer)
-- Esta política permite insertar cuando parent_id es el usuario actual
create policy "parent_students: insert via redeem_invitation_code"
  on parent_students for insert
  with check (parent_id = auth.uid());

-- Inserción solo vía redeem_invitation_code (security definer), no directa
-- invitation_codes
-- ═══════════════════════════════════════════════════════════════
alter table invitation_codes enable row level security;

create policy "invitation_codes: orientador full access"
  on invitation_codes for all
  using (is_orientador())
  with check (is_orientador());

-- Los padres pueden leer para verificar si el código es suyo (redeem_invitation_code lo maneja)
-- No se necesita policy de SELECT para padres; la función usa security definer.

-- ═══════════════════════════════════════════════════════════════
-- reports
-- ═══════════════════════════════════════════════════════════════
alter table reports enable row level security;

create policy "reports: orientador full access"
  on reports for all
  using (is_orientador())
  with check (is_orientador());

create policy "reports: padre select own child"
  on reports for select
  using (is_parent_of(student_id));

-- ═══════════════════════════════════════════════════════════════
-- justifications
-- ═══════════════════════════════════════════════════════════════
alter table justifications enable row level security;

create policy "justifications: orientador full access"
  on justifications for all
  using (is_orientador())
  with check (is_orientador());

create policy "justifications: padre select own child"
  on justifications for select
  using (is_parent_of(student_id));

-- ═══════════════════════════════════════════════════════════════
-- appointments
-- ═══════════════════════════════════════════════════════════════
alter table appointments enable row level security;

create policy "appointments: orientador full access"
  on appointments for all
  using (is_orientador())
  with check (is_orientador());

create policy "appointments: padre select own child"
  on appointments for select
  using (is_parent_of(student_id));

-- El padre puede crear una cita para su hijo
create policy "appointments: padre insert own child"
  on appointments for insert
  with check (is_parent_of(student_id) and created_by = auth.uid());

-- El padre puede confirmar lectura (read_at) o confirmar/cancelar su propia cita
create policy "appointments: padre update own"
  on appointments for update
  using (is_parent_of(student_id) and created_by = auth.uid());
