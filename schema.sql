-- Encuesta "¿Qué auto va contigo?" — tabla de respuestas (Supabase / Postgres)
create table if not exists public.encuestas_auto (
  id             bigint generated always as identity primary key,
  creado_en      timestamptz not null default now(),
  build          text,
  origen         text,                       -- ?src= del QR (cartel, stand, página)
  respuestas     jsonb not null,             -- {presupuesto:"B", uso:"A", ...}
  perfil         text not null check (perfil in ('urb','fam','tra','dep','pre','tec')),
  perfil_2       text,
  afinidad       jsonb,                      -- % por perfil
  presupuesto    text,
  temperatura    text check (temperatura in ('caliente','tibio','frío')),
  pago           text,
  nombre         text check (char_length(nombre) <= 80),
  whatsapp       text check (whatsapp ~ '^[0-9]{10}$'),
  consentimiento boolean not null default false,
  check (whatsapp is null or consentimiento)  -- sin consentimiento no se guarda teléfono
);

alter table public.encuestas_auto enable row level security;

-- El público (anon) solo puede insertar; nunca leer, editar ni borrar.
drop policy if exists anon_insert on public.encuestas_auto;
create policy anon_insert on public.encuestas_auto
  for insert to anon with check (true);

create index if not exists encuestas_auto_creado_idx on public.encuestas_auto (creado_en desc);
create index if not exists encuestas_auto_perfil_idx on public.encuestas_auto (perfil);

-- Vista rápida para el equipo (consultar con service role o usuario autenticado)
create or replace view public.encuestas_auto_resumen with (security_invoker = true) as
select date_trunc('day', creado_en) as dia, origen, perfil, temperatura, count(*) as n
from public.encuestas_auto group by 1,2,3,4;
revoke all on public.encuestas_auto_resumen from anon;
