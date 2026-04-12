-- 1. Crear la tabla de Metas (Plan Items / Goals)
CREATE TABLE public.goals (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  description text,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
  priority text DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  due_date timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- 2. Activar Seguridad de Fila (RLS)
-- ¡Esto es vital! Evita que el Usuario A vea las metas del Usuario B
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;

-- 3. Crear la "Política de Privacidad" (Policy)
-- Solo el dueño de la meta puede verla y editarla
CREATE POLICY "Users can manage their own goals" 
ON public.goals 
FOR ALL 
USING (auth.uid() = user_id);

-- 4. Trigger para el updated_at (Usamos la función que ya creamos antes)
CREATE TRIGGER handle_goals_updated_at
  BEFORE UPDATE ON public.goals
  FOR EACH ROW EXECUTE PROCEDURE moddatetime();