import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verdict/core/services/future_services.dart';
import 'package:verdict_engine/verdict_engine.dart';

class SupabaseLeaderboardServices
    implements LeaderboardRepository, AuthService {
  const SupabaseLeaderboardServices(this._client);

  final SupabaseClient _client;

  @override
  Future<String> signInAnonymously() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) return currentUser.id;
    final response = await _client.auth.signInAnonymously();
    final user = response.user;
    if (user == null) {
      throw StateError('Anonymous sign-in did not return a user.');
    }
    return user.id;
  }

  @override
  Future<String?> currentUsername() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final profile = await _client
        .from('profiles')
        .select('username')
        .eq('id', userId)
        .maybeSingle();
    return profile?['username'] as String?;
  }

  @override
  Future<String> claimUsername(String username) async {
    final result = await _client.rpc(
      'claim_username',
      params: {'requested_username': username},
    );
    return result as String;
  }

  @override
  Future<List<LeaderboardEntry>> topScores(GameMode mode) async {
    await signInAnonymously();
    final result = await _client.rpc(
      'get_leaderboard',
      params: {'requested_mode': mode.name, 'requested_limit': 10},
    );
    return (result as List<Object?>)
        .map((row) {
          final data = Map<String, Object?>.from(row! as Map);
          return LeaderboardEntry(
            username: data['username']! as String,
            score: (data['score']! as num).toInt(),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<int> submitAttempt(VerifiedAttempt attempt) async {
    await signInAnonymously();
    final result = await _client.rpc(
      'submit_daily_score',
      params: {
        'requested_puzzle_id': attempt.puzzleId,
        'requested_mode': attempt.mode.name,
        'submitted_guesses': attempt.guesses,
      },
    );
    return (result as num).toInt();
  }
}
