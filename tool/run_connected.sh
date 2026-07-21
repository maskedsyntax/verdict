#!/bin/zsh
set -euo pipefail

readonly keychain_service="com.maskedsyntax.verdict.supabase-publishable"
publishable_key="$(
  security find-generic-password \
    -a verdict \
    -s "$keychain_service" \
    -w
)"

exec flutter run \
  --dart-define=SUPABASE_URL=https://cumhjvjrdoaoehlbrkvo.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$publishable_key" \
  "$@"
