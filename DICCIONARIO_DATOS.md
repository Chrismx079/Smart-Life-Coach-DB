# 📖 Diccionario de Datos
### Proyecto IA — Asistente Inteligente Gestor de Tareas y Metas

> Base de datos: **PostgreSQL** vía Supabase  
> Esquema principal: `public`  
> Seguridad: Row Level Security (RLS) habilitada en todas las tablas

---

## Índice

- [Funciones y Triggers](#funciones-y-triggers)
- [Tabla: `users`](#tabla-users)
- [Tabla: `goals`](#tabla-goals)
- [Tabla: `chat_sessions`](#tabla-chat_sessions)
- [Tabla: `chat_messages`](#tabla-chat_messages)
- [Políticas de Seguridad (RLS)](#políticas-de-seguridad-rls)
- [Relaciones entre Tablas](#relaciones-entre-tablas)

---

## Funciones y Triggers

### Función `moddatetime()`

| Atributo | Detalle |
|---|---|
| **Tipo** | Trigger Function |
| **Lenguaje** | PL/pgSQL |
| **Propósito** | Actualiza automáticamente el campo `updated_at` al valor actual (`now()`) cada vez que se modifica un registro. |
| **Usada en** | `users`, `goals`, `chat_sessions` |

### Función `handle_new_user()`

| Atributo | Detalle |
|---|---|
| **Tipo** | Trigger Function |
| **Lenguaje** | PL/pgSQL |
| **Seguridad** | `SECURITY DEFINER` |
| **Propósito** | Sincroniza automáticamente un nuevo registro en `public.users` cada vez que un usuario se registra a través de Supabase Auth (`auth.users`). Extrae el `username` desde los metadatos del usuario (`raw_user_meta_data`). |
| **Activada por** | Trigger `on_auth_user_created` (`AFTER INSERT ON auth.users`) |

---

## Tabla: `users`

Almacena los perfiles de los usuarios de la aplicación. Se sincroniza automáticamente con `auth.users` de Supabase mediante un trigger.

| Columna | Tipo | Nulable | Default | Restricciones | Descripción |
|---|---|---|---|---|---|
| `id` | `uuid` | NO | — | `PRIMARY KEY`, `REFERENCES auth.users` | Identificador único del usuario. Vinculado directamente al sistema de autenticación de Supabase. |
| `username` | `text` | SÍ | `NULL` | `UNIQUE` | Nombre de usuario único dentro de la aplicación. Se extrae de los metadatos al registrarse. |
| `email` | `text` | SÍ | `NULL` | `UNIQUE` | Correo electrónico del usuario. |
| `age` | `int` | SÍ | `NULL` | `CHECK (age > 0)` | Edad del usuario. Debe ser un número entero positivo. |
| `created_at` | `timestamptz` | NO | `now()` | — | Fecha y hora de creación del registro. |
| `updated_at` | `timestamptz` | NO | `now()` | — | Fecha y hora de la última modificación. Actualizado automáticamente por el trigger `handle_updated_at`. |

**Triggers activos:**

| Trigger | Evento | Función |
|---|---|---|
| `handle_updated_at` | `BEFORE UPDATE` | `moddatetime()` |
| `on_auth_user_created` | `AFTER INSERT ON auth.users` | `handle_new_user()` |

---

## Tabla: `goals`

Almacena las metas y objetivos creados por cada usuario. Cada meta pertenece exclusivamente a un usuario y no puede ser vista ni modificada por otros.

| Columna | Tipo | Nulable | Default | Restricciones | Descripción |
|---|---|---|---|---|---|
| `id` | `uuid` | NO | `gen_random_uuid()` | `PRIMARY KEY` | Identificador único de la meta, generado automáticamente. |
| `user_id` | `uuid` | NO | — | `REFERENCES users(id) ON DELETE CASCADE` | Usuario propietario de la meta. Al eliminar el usuario, sus metas se eliminan en cascada. |
| `parent_id` | `uuid` | SÍ | `NULL` | `REFERENCES goals(id) ON DELETE CASCADE` | Referencia a una meta padre. Permite crear submetas (jerarquía recursiva). Al eliminar la meta padre, las submetas se eliminan en cascada. |
| `title` | `text` | NO | — | — | Título o nombre de la meta. |
| `description` | `text` | SÍ | `NULL` | — | Descripción detallada opcional de la meta. |
| `status` | `text` | SÍ | `'pending'` | `CHECK (status IN ('pending', 'in_progress', 'completed'))` | Estado actual de la meta. |
| `priority` | `text` | SÍ | `'medium'` | `CHECK (priority IN ('low', 'medium', 'high'))` | Nivel de prioridad asignado a la meta. |
| `due_date` | `timestamptz` | SÍ | `NULL` | — | Fecha límite opcional para completar la meta. |
| `created_at` | `timestamptz` | NO | `now()` | — | Fecha y hora de creación del registro. |
| `updated_at` | `timestamptz` | NO | `now()` | — | Fecha y hora de la última modificación. Actualizado automáticamente por el trigger. |

**Valores permitidos — `status`:**

| Valor | Significado |
|---|---|
| `pending` | Meta pendiente de iniciar *(default)* |
| `in_progress` | Meta en progreso |
| `completed` | Meta completada |

**Valores permitidos — `priority`:**

| Valor | Significado |
|---|---|
| `low` | Prioridad baja |
| `medium` | Prioridad media *(default)* |
| `high` | Prioridad alta |

**Triggers activos:**

| Trigger | Evento | Función |
|---|---|---|
| `handle_goals_updated_at` | `BEFORE UPDATE` | `moddatetime()` |

---

## Tabla: `chat_sessions`

Agrupa los mensajes de chat en conversaciones independientes. Cada sesión pertenece a un único usuario.

| Columna | Tipo | Nulable | Default | Restricciones | Descripción |
|---|---|---|---|---|---|
| `id` | `uuid` | NO | `gen_random_uuid()` | `PRIMARY KEY` | Identificador único de la sesión, generado automáticamente. |
| `user_id` | `uuid` | NO | — | `REFERENCES users(id) ON DELETE CASCADE` | Usuario propietario de la sesión. Al eliminar el usuario, sus sesiones se eliminan en cascada. |
| `title` | `text` | SÍ | `'Nueva conversacion'` | — | Título descriptivo de la conversación. |
| `created_at` | `timestamptz` | NO | `now()` | — | Fecha y hora de creación de la sesión. |
| `updated_at` | `timestamptz` | NO | `now()` | — | Fecha y hora de la última modificación. Actualizado automáticamente por el trigger. |

**Triggers activos:**

| Trigger | Evento | Función |
|---|---|---|
| `handle_sessions_updated_at` | `BEFORE UPDATE` | `moddatetime()` |

---

## Tabla: `chat_messages`

Almacena el historial completo de mensajes de cada sesión de chat, incluyendo tanto los mensajes del usuario como las respuestas del asistente de IA.

| Columna | Tipo | Nulable | Default | Restricciones | Descripción |
|---|---|---|---|---|---|
| `id` | `uuid` | NO | `gen_random_uuid()` | `PRIMARY KEY` | Identificador único del mensaje, generado automáticamente. |
| `session_id` | `uuid` | NO | — | `REFERENCES chat_sessions(id) ON DELETE CASCADE` | Sesión a la que pertenece el mensaje. Al eliminar la sesión, sus mensajes se eliminan en cascada. |
| `sender` | `text` | NO | — | `CHECK (sender IN ('user', 'ai'))` | Indica quién envió el mensaje: el usuario o la IA. |
| `content` | `text` | NO | — | — | Contenido completo del mensaje. |
| `created_at` | `timestamptz` | NO | `now()` | — | Fecha y hora en que se creó el mensaje. |

> `chat_messages` **no tiene** campo `updated_at` ya que los mensajes no se modifican una vez enviados.

**Valores permitidos — `sender`:**

| Valor | Significado |
|---|---|
| `user` | Mensaje enviado por el usuario |
| `ai` | Respuesta generada por el asistente de IA |

---

## Políticas de Seguridad (RLS)

Todas las tablas tienen **Row Level Security** habilitado. Las políticas garantizan que cada usuario solo pueda acceder a sus propios datos.

| Tabla | Política | Operación | Condición |
|---|---|---|---|
| `users` | `Users can view their own profile` | `SELECT` | `auth.uid() = id` |
| `users` | `Users can update their own profile` | `UPDATE` | `auth.uid() = id` |
| `goals` | `Users can manage their own goals` | `ALL` | `auth.uid() = user_id` |
| `chat_sessions` | `Users can manage their own sessions` | `ALL` | `auth.uid() = user_id` |
| `chat_messages` | `Users can manage messages of their sessions` | `ALL` | El `session_id` del mensaje debe pertenecer a una sesión del usuario autenticado |

---

## Relaciones entre Tablas

```
auth.users (Supabase Auth)
    │
    │ trigger: on_auth_user_created
    ▼
public.users
    │
    ├──── public.goals ◄──────────────────┐
    │         (user_id → users.id,         │ (parent_id → goals.id,
    │          CASCADE DELETE)             │  CASCADE DELETE)
    │                                      └──────────────────────┘
    └──── public.chat_sessions
              (user_id → users.id, CASCADE DELETE)
                   │
                   └──── public.chat_messages
                             (session_id → chat_sessions.id, CASCADE DELETE)
```

> **Cascada de eliminación:** Si se elimina un `user`, se eliminan en cascada todas sus `goals`, `chat_sessions` y, por extensión, todos sus `chat_messages`.
