# Supabase Phase 2

No Supabase client or credentials are required by the MVP.

Phase 2 will add migrations for anonymous profiles, dated puzzles, server-issued
attempts, and per-mode scores. Score submission should go through a Postgres RPC
that receives the guess sequence and validates the puzzle, dictionary entries,
mode rules, guess count, and server-recorded attempt window. Clients must not be
allowed to insert a raw score directly.

Required deployment configuration will be supplied through CI secrets and
build-time environment values, never committed to this directory.
