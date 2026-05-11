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
docker compose up -d
```

> Este comando usa el archivo `docker-compose.yml` incluido en la raíz del proyecto. Redis se levantará en el puerto `6379` con persistencia de datos activada y se reiniciará automáticamente si Docker Desktop se reinicia.

---

## 🔐 Credenciales de Conexión

### .env

En el archivo .env se usan las claves generadas en console.cloud.google.com/ en especifico la google auth platform, donde generas tu cliente de autenticacion, se recomienda añadir las siguientes URIs en "Authorized redirect URIs":
http://127.0.0.1:54321/auth/v1/callback
http://localhost:54321/auth/v1/callback

El SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID= siempre se puede consultar en la google auth platform, pero el SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET= solo se puede ver una vez creadas

---

## 🏛️ Estructura de la Base de Datos

He configurado las siguientes tablas con **Seguridad de Nivel de Fila (RLS)**:

| Tabla           | Descripción                                             |
| --------------- | ------------------------------------------------------- |
| `users`         | Perfiles de usuario sincronizados automáticamente.      |
| `goals`         | Metas y objetivos del usuario.                          |
| `chat_sessions` | Agrupador de conversaciones.                            |
| `chat_messages` | Historial de mensajes (optimizado para contexto de IA). |

---

**Para ver el detalle técnico de las tablas, consulta el [Diccionario de Datos](./DICCIONARIO_DATOS.md)**

## ⚙️ Comandos Útiles

```powershell
# Ver estado y llaves
npx supabase status

# Detener Supabase
npx supabase stop

# Detener Redis
docker compose down

# Resetear base de datos
npx supabase db reset
```

---

## 💡 Notas para el desarrollador

He dejado configurado un **Trigger** que crea automáticamente un perfil en la tabla `public.users` cada vez que alguien se registra a través de **Supabase Auth**. No necesitas crear el perfil manualmente.

Tambien he incluido un script [`TEST_CONNECTION.js`](./TEST_CONNECTION.js) para verificar la conectividad. Para ejecutarlo, usa `node TEST_CONNECTION.js` (requiere haber configurado el `.env`).
