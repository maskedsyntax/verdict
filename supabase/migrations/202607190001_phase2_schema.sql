create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_username_format check (username ~ '^[A-Za-z0-9_]{3,20}$')
);

create unique index profiles_username_lower_key
  on public.profiles (lower(username));

create table public.valid_words (
  word text primary key,
  constraint valid_words_format check (word ~ '^[a-z]{5}$')
);

create table public.puzzles (
  id text primary key,
  mode text not null,
  puzzle_date date not null,
  puzzle_number integer not null check (puzzle_number > 0),
  answer text not null references public.valid_words (word),
  max_guesses integer not null check (max_guesses > 0),
  score_multiplier integer not null default 1 check (score_multiplier > 0),
  unique (mode, puzzle_date)
);

create table public.scores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  mode text not null,
  puzzle_id text not null references public.puzzles (id),
  score integer not null check (score >= 0),
  guess_count integer not null check (guess_count > 0),
  submitted_at timestamptz not null default now(),
  unique (user_id, puzzle_id)
);

create index scores_mode_score_index
  on public.scores (mode, score desc);

alter table public.profiles enable row level security;
alter table public.valid_words enable row level security;
alter table public.puzzles enable row level security;
alter table public.scores enable row level security;

create policy "authenticated users can read public profiles"
  on public.profiles for select
  to authenticated
  using (true);

grant select on public.profiles to authenticated;
revoke insert, update, delete on public.profiles from anon, authenticated;
revoke all on public.valid_words from anon, authenticated;
revoke all on public.puzzles from anon, authenticated;
revoke all on public.scores from anon, authenticated;

create or replace function public.claim_username(requested_username text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
  normalized_username text := btrim(requested_username);
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;
  if normalized_username !~ '^[A-Za-z0-9_]{3,20}$' then
    raise exception 'Username must be 3-20 letters, numbers, or underscores';
  end if;

  insert into public.profiles (id, username)
  values (current_user_id, normalized_username)
  on conflict (id) do update
    set username = excluded.username,
        updated_at = now();

  return normalized_username;
exception
  when unique_violation then
    raise exception 'Username is already taken';
end;
$$;

create or replace function public.submit_daily_score(
  requested_puzzle_id text,
  requested_mode text,
  submitted_guesses text[]
)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
  selected_puzzle public.puzzles%rowtype;
  submitted_count integer := cardinality(submitted_guesses);
  calculated_score integer;
  existing_score integer;
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;
  if not exists (
    select 1 from public.profiles where id = current_user_id
  ) then
    raise exception 'Claim a username before submitting a score';
  end if;

  select * into selected_puzzle
  from public.puzzles
  where id = requested_puzzle_id
    and mode = requested_mode
    and puzzle_date = (timezone('utc', now()))::date;

  if not found then
    raise exception 'Daily puzzle is not available';
  end if;

  select score into existing_score
  from public.scores
  where user_id = current_user_id
    and puzzle_id = selected_puzzle.id;
  if found then
    return existing_score;
  end if;

  if submitted_count is null
    or submitted_count < 1
    or submitted_count > selected_puzzle.max_guesses then
    raise exception 'Invalid guess count';
  end if;
  if exists (
    select 1
    from unnest(submitted_guesses) as submitted(word)
    where submitted.word !~ '^[a-z]{5}$'
      or not exists (
        select 1
        from public.valid_words as valid
        where valid.word = submitted.word
      )
  ) then
    raise exception 'Guess sequence contains an invalid word';
  end if;
  if submitted_guesses[submitted_count] <> selected_puzzle.answer then
    raise exception 'Guess sequence does not solve this puzzle';
  end if;

  calculated_score := (
    1000 + (selected_puzzle.max_guesses - submitted_count) * 100
  ) * selected_puzzle.score_multiplier;

  insert into public.scores (
    user_id,
    mode,
    puzzle_id,
    score,
    guess_count
  ) values (
    current_user_id,
    selected_puzzle.mode,
    selected_puzzle.id,
    calculated_score,
    submitted_count
  )
  on conflict (user_id, puzzle_id) do nothing;

  select score into existing_score
  from public.scores
  where user_id = current_user_id
    and puzzle_id = selected_puzzle.id;
  return existing_score;
end;
$$;

create or replace function public.get_leaderboard(
  requested_mode text default 'classic',
  requested_limit integer default 10
)
returns table (username text, score bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select profiles.username, sum(scores.score)::bigint as score
  from public.scores as scores
  join public.profiles as profiles on profiles.id = scores.user_id
  where scores.mode = requested_mode
  group by profiles.id, profiles.username
  order by score desc, min(scores.submitted_at)
  limit least(greatest(requested_limit, 1), 100)
$$;

revoke all on function public.claim_username(text) from public, anon;
revoke all on function public.submit_daily_score(text, text, text[]) from public, anon;
revoke all on function public.get_leaderboard(text, integer) from public, anon;
grant execute on function public.claim_username(text) to authenticated;
grant execute on function public.submit_daily_score(text, text, text[]) to authenticated;
grant execute on function public.get_leaderboard(text, integer) to authenticated;
