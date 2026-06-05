-- ============================================================
-- Migración: Remover expiración y reutilización en codes
-- Ejecutar en: Supabase > SQL Editor
-- ============================================================

-- Remover columnas innecesarias
ALTER TABLE invitation_codes 
DROP COLUMN IF EXISTS used_by,
DROP COLUMN IF EXISTS expires_at;

-- Recrear la función redeem_invitation_code con manejo de errores
create or replace function redeem_invitation_code(p_code text)
returns json language plpgsql security definer as $$
declare
  v_code_row invitation_codes%rowtype;
  v_caller_id uuid := auth.uid();
  v_affected_rows bigint;
begin
  -- Validar que el usuario está autenticado
  if v_caller_id is null then
    return json_build_object('success', false, 'error', 'No hay sesión activa.');
  end if;

  -- Buscar el código
  select * into v_code_row
  from invitation_codes
  where code = p_code;

  if not found then
    return json_build_object('success', false, 'error', 'Código inválido o no existe.');
  end if;

  -- Vincular padre con alumno
  insert into parent_students (parent_id, student_id)
  values (v_caller_id, v_code_row.student_id)
  on conflict do nothing;

  -- Verificar que la inserción fue exitosa
  get diagnostics v_affected_rows = row_count;
  if v_affected_rows = 0 then
    return json_build_object('success', false, 'error', 'Este alumno ya está vinculado a tu cuenta.');
  end if;

  return json_build_object('success', true, 'student_id', v_code_row.student_id);
end;
$$;

-- Agregar política RLS para permitir inserciones desde la función
-- (Ejecutar esto en SQL si la tabla ya tiene RLS habilitado)
create policy if not exists "parent_students: insert via redeem_invitation_code"
  on parent_students for insert
  with check (parent_id = auth.uid());

