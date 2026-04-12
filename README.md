# 🚀 Proyecto IA (Asistente inteligente gestor de tareas y metas) + Supabase: Infraestructura Local

Este repositorio contiene la configuración completa de la base de datos y el sistema de caché para la aplicación.

---

## 📋 Requisitos Previos

- **Docker Desktop** (Debe estar abierto y corriendo).
- **Node.js** (Para ejecutar los comandos `npx`).

---

## 🛠️ Instrucciones de Inicio

Para levantar todo el ecosistema, ejecuta los siguientes dos comandos en la terminal desde la raíz del proyecto (carpeta `proyecto-ia-supabase`):

### 1. Levantar Supabase (Base de Datos, Auth, API)

```powershell
npx supabase start
```

Esto aplicará automáticamente las migraciones (tablas, RLS, triggers) que se encuentran en la carpeta `./supabase/migrations`.

### 2. Levantar Redis (Caché para la IA)

```powershell
docker run -d --name redis-ia -p 6379:6379 redis:alpine
```

---

## 🔐 Credenciales de Conexión

### Backend (Node.js / Python)

| Variable | Valor |
|---|---|
| **Postgres URL** | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |
| **Redis URL** | `redis://localhost:6379` |
| **Service Role Key** | Ver nota abajo ↓ |

> He incluido un archivo `.env.example`. Cámbiale el nombre a `.env` y completa el valor de `SERVICE_ROLE_KEY` con la **Authentication Key (Secret)** que aparece al ejecutar `npx supabase status`.

### Frontend (React / Vue / Flutter)

| Variable | Valor |
|---|---|
| **Project URL** | `http://127.0.0.1:54321` |
| **Anon Key** | Ver nota abajo ↓ |

> Completa el valor de `ANON_KEY` en tu `.env` con la **Authentication Key (Publishable)** que aparece al ejecutar `npx supabase status`.

---

## 🏛️ Estructura de la Base de Datos

He configurado las siguientes tablas con **Seguridad de Nivel de Fila (RLS)**:

| Tabla | Descripción |
|---|---|
| `users` | Perfiles de usuario sincronizados automáticamente. |
| `goals` | Metas y objetivos del usuario. |
| `chat_sessions` | Agrupador de conversaciones. |
| `chat_messages` | Historial de mensajes (optimizado para contexto de IA). |

---

**Para ver el detalle técnico de las tablas, consulta el [Diccionario de Datos](./DICCIONARIO_DATOS.md)**

## ⚙️ Comandos Útiles

```powershell
# Ver estado y llaves
npx supabase status

# Detener todo
npx supabase stop

# Resetear base de datos
npx supabase db reset
```

---

## 💡 Notas para el desarrollador

He dejado configurado un **Trigger** que crea automáticamente un perfil en la tabla `public.users` cada vez que alguien se registra a través de **Supabase Auth**. No necesitas crear el perfil manualmente.

Tambien he incluido un script [`TEST_CONNECTION.js`](./TEST_CONNECTION.js) para verificar la conectividad. Para ejecutarlo, usa `node TEST_CONNECTION.js` (requiere haber configurado el `.env`).

