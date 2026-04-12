-- 1. Tabla de Sesiones de Chat
CREATE TABLE public.chat_sessions (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  title text DEFAULT 'Nueva conversación',
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- 2. Tabla de Mensajes (Aquí vive la historia)
CREATE TABLE public.chat_messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id uuid REFERENCES public.chat_sessions(id) ON DELETE CASCADE NOT NULL,
  sender text CHECK (sender IN ('user', 'ai')) NOT NULL,
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- 3. Habilitar Seguridad (RLS)
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- 4. Políticas: Solo el dueño puede ver sus chats
CREATE POLICY "Users can manage their own sessions" 
  ON public.chat_sessions FOR ALL USING (auth.uid() = user_id);

-- Para los mensajes, el acceso es si eres dueño de la sesión a la que pertenecen
CREATE POLICY "Users can manage messages of their sessions" 
  ON public.chat_messages FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.chat_sessions 
      WHERE id = chat_messages.session_id AND user_id = auth.uid()
    )
  );

-- 5. Trigger para updated_at en sesiones
CREATE TRIGGER handle_sessions_updated_at
  BEFORE UPDATE ON public.chat_sessions
  FOR EACH ROW EXECUTE PROCEDURE moddatetime();