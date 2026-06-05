-- ============================================================
-- Migración: Remover expiración y reutilización en codes
-- Ejecutar en: Supabase > SQL Editor
-- ============================================================

-- Remover columnas innecesarias
ALTER TABLE invitation_codes 
DROP COLUMN IF EXISTS used_by,
DROP COLUMN IF EXISTS expires_at;

-- Recrear la función redeem_invitation_code para códigos reutilizables
create or replace function redeem_invitation_code(p_code text)
returns json language plpgsql security definer as $$
declare
  v_code_row invitation_codes%rowtype;
  v_caller_id uuid := auth.uid();
begin
  -- Buscar el código (sin verificar expiración ni usado_by)
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

  return json_build_object('success', true, 'student_id', v_code_row.student_id);
end;
$$;
