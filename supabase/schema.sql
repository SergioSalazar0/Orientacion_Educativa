-- ============================================================
-- schema.sql
-- Ejecutar en: Supabase > SQL Editor
-- Orden: 1) schema.sql  2) rls.sql  3) storage.sql
-- ============================================================

-- Habilitar la extensión UUID (normalmente ya está activa en Supabase)
create extension if not exists "pgcrypto";

-- ── Tipos ENUM ────────────────────────────────────────────────────────────
create type user_role as enum ('orientador', 'padre');
create type student_status as enum ('activo', 'baja');
create type report_category as enum ('conducta', 'rendimiento', 'asistencia', 'otro');
create type justification_status as enum ('pendiente', 'aprobado', 'rechazado');
create type appointment_status as enum ('programada', 'confirmada', 'cancelada');
create type appointment_reason as enum ('vocacional', 'academico', 'personal', 'seguimiento');
create type semester_type as enum ('1', '2', '3', '4', '5', '6');

-- ── TABLA: profiles ───────────────────────────────────────────────────────
-- Se crea automáticamente al registrarse (ver trigger handle_new_user).
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  full_name   text not null default '',
  role        user_role not null default 'padre',
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ── TABLA: students ───────────────────────────────────────────────────────
create table students (
  id              uuid primary key default gen_random_uuid(),
  student_code    text not null unique,               -- Matrícula
  full_name       text not null,
  semester        semester_type not null,
  "group"         text not null,
  specialty       text not null,
  photo_url       text,
  status          student_status not null default 'activo',
  birth_date      date,
  address         text,
  blood_type      text,
  insurance       text,
  nss             text,
  allergies       text,
  medical_notes   text,
  created_by      uuid references profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index idx_students_status      on students(status);
create index idx_students_semester    on students(semester);
create index idx_students_group       on students("group");
create index idx_students_specialty   on students(specialty);
create index idx_students_created_by  on students(created_by);

-- ── TABLA: guardians (tutores/contactos del alumno) ───────────────────────
create table guardians (
  id           uuid primary key default gen_random_uuid(),
  student_id   uuid not null references students(id) on delete cascade,
  relationship text not null,     -- papá, mamá, tutor, abuelo, etc.
  full_name    text not null,
  phone        text,
  address      text,
  created_at   timestamptz not null default now()
);

create index idx_guardians_student_id on guardians(student_id);

-- ── TABLA: parent_students (vínculo N:M padre ↔ alumno) ───────────────────
create table parent_students (
  parent_id   uuid not null references profiles(id) on delete cascade,
  student_id  uuid not null references students(id) on delete cascade,
  linked_at   timestamptz not null default now(),
  primary key (parent_id, student_id)
);

-- ── TABLA: invitation_codes ────────────────────────────────────────────────
create table invitation_codes (
  id          uuid primary key default gen_random_uuid(),
  code        text not null unique,
  student_id  uuid not null references students(id) on delete cascade,
  used_by     uuid references profiles(id),
  expires_at  timestamptz not null,
  created_at  timestamptz not null default now()
);

create index idx_invitation_codes_student_id on invitation_codes(student_id);
create index idx_invitation_codes_code       on invitation_codes(code);

-- ── TABLA: reports ────────────────────────────────────────────────────────
create table reports (
  id          uuid primary key default gen_random_uuid(),
  student_id  uuid not null references students(id) on delete cascade,
  category    report_category not null default 'otro',
  title       text not null,
  description text not null,
  image_url   text,
  created_by  uuid references profiles(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index idx_reports_student_id  on reports(student_id);
create index idx_reports_category    on reports(category);
create index idx_reports_created_by  on reports(created_by);

-- ── TABLA: justifications ─────────────────────────────────────────────────
create table justifications (
  id           uuid primary key default gen_random_uuid(),
  student_id   uuid not null references students(id) on delete cascade,
  reason       text not null,
  description  text,
  date         date not null,
  status       justification_status not null default 'pendiente',
  file_url     text,
  created_by   uuid references profiles(id),
  reviewed_by  uuid references profiles(id),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index idx_justifications_student_id on justifications(student_id);
create index idx_justifications_status     on justifications(status);

-- ── TABLA: appointments ───────────────────────────────────────────────────
create table appointments (
  id             uuid primary key default gen_random_uuid(),
  student_id     uuid not null references students(id) on delete cascade,
  guardian_name  text not null,
  date           date not null,
  time           time not null,
  reason         appointment_reason not null,
  notes          text,
  status         appointment_status not null default 'programada',
  orientador_id  uuid references profiles(id),
  created_by     uuid references profiles(id),
  read_at        timestamptz,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index idx_appointments_student_id    on appointments(student_id);
create index idx_appointments_date          on appointments(date);
create index idx_appointments_status        on appointments(status);
create index idx_appointments_orientador_id on appointments(orientador_id);

-- ── TRIGGER: actualiza updated_at automáticamente ─────────────────────────
create or replace function update_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_students_updated_at
  before update on students
  for each row execute function update_updated_at();

create trigger trg_reports_updated_at
  before update on reports
  for each row execute function update_updated_at();

create trigger trg_justifications_updated_at
  before update on justifications
  for each row execute function update_updated_at();

create trigger trg_appointments_updated_at
  before update on appointments
  for each row execute function update_updated_at();

create trigger trg_profiles_updated_at
  before update on profiles
  for each row execute function update_updated_at();

-- ── TRIGGER: crea fila en profiles al registrarse un usuario ─────────────
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    'padre'   -- por defecto todos son padres; el orientador se eleva manualmente
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ── FUNCIÓN: canjear código de invitación ─────────────────────────────────
-- security definer para que el padre pueda insertar en parent_students
-- sin necesitar privilegios directos sobre la tabla.
create or replace function redeem_invitation_code(p_code text)
returns json language plpgsql security definer as $$
declare
  v_code_row invitation_codes%rowtype;
  v_caller_id uuid := auth.uid();
begin
  -- Buscar el código
  select * into v_code_row
  from invitation_codes
  where code = p_code
    and used_by is null
    and expires_at > now();

  if not found then
    return json_build_object('success', false, 'error', 'Código inválido, ya usado o expirado.');
  end if;

  -- Vincular padre con alumno
  insert into parent_students (parent_id, student_id)
  values (v_caller_id, v_code_row.student_id)
  on conflict do nothing;

  -- Marcar código como usado
  update invitation_codes
  set used_by = v_caller_id
  where id = v_code_row.id;

  return json_build_object('success', true, 'student_id', v_code_row.student_id);
end;
$$;
