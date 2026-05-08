
  create table "public"."chat_messages" (
    "id" uuid not null default gen_random_uuid(),
    "session_id" uuid not null,
    "sender" text not null,
    "content" text not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."chat_messages" enable row level security;


  create table "public"."chat_sessions" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "title" text default 'Nueva conversacion'::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."chat_sessions" enable row level security;


  create table "public"."goals" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "parent_id" uuid,
    "title" text not null,
    "description" text,
    "status" text default 'pending'::text,
    "priority" text default 'medium'::text,
    "due_date" timestamp with time zone,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );

alter table "public"."goals" enable row level security;


  create table "public"."users" (
    "id" uuid not null,
    "username" text,
    "email" text,
    "age" integer,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."users" enable row level security;

CREATE UNIQUE INDEX chat_messages_pkey ON public.chat_messages USING btree (id);

CREATE UNIQUE INDEX chat_sessions_pkey ON public.chat_sessions USING btree (id);

CREATE UNIQUE INDEX goals_pkey ON public.goals USING btree (id);

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);

alter table "public"."chat_messages" add constraint "chat_messages_pkey" PRIMARY KEY using index "chat_messages_pkey";

alter table "public"."chat_sessions" add constraint "chat_sessions_pkey" PRIMARY KEY using index "chat_sessions_pkey";

alter table "public"."goals" add constraint "goals_pkey" PRIMARY KEY using index "goals_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."chat_messages" add constraint "chat_messages_sender_check" CHECK ((sender = ANY (ARRAY['user'::text, 'ai'::text]))) not valid;

alter table "public"."chat_messages" validate constraint "chat_messages_sender_check";

alter table "public"."chat_messages" add constraint "chat_messages_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.chat_sessions(id) ON DELETE CASCADE not valid;

alter table "public"."chat_messages" validate constraint "chat_messages_session_id_fkey";

alter table "public"."chat_sessions" add constraint "chat_sessions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."chat_sessions" validate constraint "chat_sessions_user_id_fkey";

alter table "public"."goals" add constraint "goals_priority_check" CHECK ((priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text]))) not valid;

alter table "public"."goals" validate constraint "goals_priority_check";

alter table "public"."goals" add constraint "goals_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'completed'::text]))) not valid;

alter table "public"."goals" validate constraint "goals_status_check";

alter table "public"."goals" add constraint "goals_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."goals" validate constraint "goals_user_id_fkey";

alter table "public"."goals" add constraint "goals_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.goals(id) ON DELETE CASCADE not valid;

alter table "public"."goals" validate constraint "goals_parent_id_fkey";

alter table "public"."users" add constraint "users_age_check" CHECK ((age > 0)) not valid;

alter table "public"."users" validate constraint "users_age_check";

alter table "public"."users" add constraint "users_email_key" UNIQUE using index "users_email_key";

alter table "public"."users" add constraint "users_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) not valid;

alter table "public"."users" validate constraint "users_id_fkey";

alter table "public"."users" add constraint "users_username_key" UNIQUE using index "users_username_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.users (id, email, username)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'username');
  RETURN new;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.moddatetime()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

grant delete on table "public"."chat_messages" to "anon";

grant insert on table "public"."chat_messages" to "anon";

grant references on table "public"."chat_messages" to "anon";

grant select on table "public"."chat_messages" to "anon";

grant trigger on table "public"."chat_messages" to "anon";

grant truncate on table "public"."chat_messages" to "anon";

grant update on table "public"."chat_messages" to "anon";

grant delete on table "public"."chat_messages" to "authenticated";

grant insert on table "public"."chat_messages" to "authenticated";

grant references on table "public"."chat_messages" to "authenticated";

grant select on table "public"."chat_messages" to "authenticated";

grant trigger on table "public"."chat_messages" to "authenticated";

grant truncate on table "public"."chat_messages" to "authenticated";

grant update on table "public"."chat_messages" to "authenticated";

grant delete on table "public"."chat_messages" to "service_role";

grant insert on table "public"."chat_messages" to "service_role";

grant references on table "public"."chat_messages" to "service_role";

grant select on table "public"."chat_messages" to "service_role";

grant trigger on table "public"."chat_messages" to "service_role";

grant truncate on table "public"."chat_messages" to "service_role";

grant update on table "public"."chat_messages" to "service_role";

grant delete on table "public"."chat_sessions" to "anon";

grant insert on table "public"."chat_sessions" to "anon";

grant references on table "public"."chat_sessions" to "anon";

grant select on table "public"."chat_sessions" to "anon";

grant trigger on table "public"."chat_sessions" to "anon";

grant truncate on table "public"."chat_sessions" to "anon";

grant update on table "public"."chat_sessions" to "anon";

grant delete on table "public"."chat_sessions" to "authenticated";

grant insert on table "public"."chat_sessions" to "authenticated";

grant references on table "public"."chat_sessions" to "authenticated";

grant select on table "public"."chat_sessions" to "authenticated";

grant trigger on table "public"."chat_sessions" to "authenticated";

grant truncate on table "public"."chat_sessions" to "authenticated";

grant update on table "public"."chat_sessions" to "authenticated";

grant delete on table "public"."chat_sessions" to "service_role";

grant insert on table "public"."chat_sessions" to "service_role";

grant references on table "public"."chat_sessions" to "service_role";

grant select on table "public"."chat_sessions" to "service_role";

grant trigger on table "public"."chat_sessions" to "service_role";

grant truncate on table "public"."chat_sessions" to "service_role";

grant update on table "public"."chat_sessions" to "service_role";

grant delete on table "public"."goals" to "anon";

grant insert on table "public"."goals" to "anon";

grant references on table "public"."goals" to "anon";

grant select on table "public"."goals" to "anon";

grant trigger on table "public"."goals" to "anon";

grant truncate on table "public"."goals" to "anon";

grant update on table "public"."goals" to "anon";

grant delete on table "public"."goals" to "authenticated";

grant insert on table "public"."goals" to "authenticated";

grant references on table "public"."goals" to "authenticated";

grant select on table "public"."goals" to "authenticated";

grant trigger on table "public"."goals" to "authenticated";

grant truncate on table "public"."goals" to "authenticated";

grant update on table "public"."goals" to "authenticated";

grant delete on table "public"."goals" to "service_role";

grant insert on table "public"."goals" to "service_role";

grant references on table "public"."goals" to "service_role";

grant select on table "public"."goals" to "service_role";

grant trigger on table "public"."goals" to "service_role";

grant truncate on table "public"."goals" to "service_role";

grant update on table "public"."goals" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";


  create policy "Users can manage messages of their sessions"
  on "public"."chat_messages"
  as permissive
  for all
  to public
using (
    exists (
      select 1
      from public.chat_sessions
      where (
        chat_sessions.id = chat_messages.session_id
        and chat_sessions.user_id = auth.uid()
      )
    )
  )
  with check (
    exists (
      select 1
      from public.chat_sessions
      where (
        chat_sessions.id = chat_messages.session_id
        and chat_sessions.user_id = auth.uid()
      )
    )
  );



  create policy "Users can manage their own sessions"
  on "public"."chat_sessions"
  as permissive
  for all
  to public
using (auth.uid() = user_id)
  with check (auth.uid() = user_id);



  create policy "Users can manage their own goals"
  on "public"."goals"
  as permissive
  for all
  to public
using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


  create policy "Users can view their own profile"
  on "public"."users"
  for select
  to public
using ( auth.uid() = id );

  create policy "Users can update their own profile"
  on "public"."users"
  for update
  to public
using ( auth.uid() = id )
  with check ( auth.uid() = id );


CREATE TRIGGER handle_sessions_updated_at BEFORE UPDATE ON public.chat_sessions FOR EACH ROW EXECUTE FUNCTION public.moddatetime();

CREATE TRIGGER handle_goals_updated_at BEFORE UPDATE ON public.goals FOR EACH ROW EXECUTE FUNCTION public.moddatetime();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.moddatetime();

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();



