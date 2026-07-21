import 'dart:io';

import 'package:supabase/supabase.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/verify_hosted_supabase.dart URL PUBLISHABLE_KEY',
    );
    exitCode = 64;
    return;
  }

  final client = SupabaseClient(arguments[0], arguments[1]);
  final auth = await client.auth.signInAnonymously();
  final user = auth.user;
  if (user == null) throw StateError('Anonymous sign-in returned no user.');

  final username = 'Smoke${DateTime.now().millisecondsSinceEpoch}';
  await client.rpc('claim_username', params: {'requested_username': username});

  final now = DateTime.now().toUtc();
  final date = DateTime.utc(now.year, now.month, now.day);
  final epoch = DateTime.utc(2026);
  final offset = date.difference(epoch).inDays;
  final answers = File('assets/words/answers.txt').readAsLinesSync();
  final answer = answers[offset % answers.length];
  final dateKey =
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
  final score = await client.rpc(
    'submit_daily_score',
    params: {
      'requested_puzzle_id': 'classic-$dateKey',
      'requested_mode': 'classic',
      'submitted_guesses': [answer],
    },
  );
  final leaderboard = await client.rpc(
    'get_leaderboard',
    params: {'requested_mode': 'classic', 'requested_limit': 10},
  );
  final found = (leaderboard as List).any(
    (entry) => (entry as Map)['username'] == username,
  );
  if (!found) throw StateError('Submitted score was missing from leaderboard.');

  stdout.writeln('Hosted smoke test passed with score $score.');
  stdout.writeln('SMOKE_USER_ID=${user.id}');
  await client.dispose();
}
