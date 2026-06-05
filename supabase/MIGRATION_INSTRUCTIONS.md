# Instrucciones de Migración: Códigos de Invitación Reutilizables

## Cambios Realizados

La tabla `invitation_codes` ha sido actualizada para soportar códigos **reutilizables sin expiración**.

### Columnas Removidas
- `used_by` (uuid) - Ya no se registra quién usó el código
- `expires_at` (timestamptz) - Los códigos ya no expiran

### Nueva Estructura
```sql
invitation_codes (
  id uuid PRIMARY KEY,
  code text UNIQUE NOT NULL,
  student_id uuid NOT NULL REFERENCES students(id),
  created_at timestamptz NOT NULL DEFAULT now()
)
```

## Pasos para Aplicar la Migración

### Si estás usando Supabase con una base existente:

1. **Abre Supabase SQL Editor**: https://app.supabase.com/project/[TU_PROJECT_ID]/sql
2. **Ejecuta el siguiente SQL** (en orden):

```sql
-- 1. Remover columnas innecesarias
ALTER TABLE invitation_codes 
DROP COLUMN IF EXISTS used_by,
DROP COLUMN IF EXISTS expires_at;

-- 2. Recrear la función redeem_invitation_code
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
```

### Si estás creando la base desde cero:

Los archivos `schema.sql` han sido actualizados. Solo necesitas ejecutar en orden:
1. schema.sql
2. rls.sql
3. storage.sql

## Verificación

Para verificar que la migración fue exitosa, ejecuta:

```sql
-- Verificar estructura de la tabla
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'invitation_codes';

-- Resultado esperado:
-- id          | uuid
-- code        | text
-- student_id  | uuid
-- created_at  | timestamp with time zone
```

## Beneficios

✅ **Códigos únicos por alumno** - No hay duplicados  
✅ **Reutilizables sin límite** - Se puede usar ilimitadamente  
✅ **Sin expiración** - El código nunca vence  
✅ **Menos redundancia** - No se registran datos innecesarios  

## Prueba de Funcionalidad

1. Obtén un código de invitación del perfil del alumno (en el panel del orientador)
2. Como padre, ve a: `/padre/vincular-hijo`
3. Ingresa el código
4. ¡Debería funcionar sin problemas!
