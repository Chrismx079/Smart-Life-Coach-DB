-- 1. Función para actualizar el timestamp automáticamente (Se crea una sola vez)
CREATE OR REPLACE FUNCTION moddatetime()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Tabla de usuarios con todas las de la ley
CREATE TABLE public.users (
  id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
  username text UNIQUE,
  email text UNIQUE,
  age int CHECK (age > 0),
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- 3. Activar seguridad
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 4. Trigger para el updated_at
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE PROCEDURE moddatetime();

-- 5. Función de sincronización con Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, username)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'username');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Trigger de sincronización
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();