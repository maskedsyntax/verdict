import 'dart:async';

import 'package:verdict_engine/verdict_engine.dart';

abstract interface class LeaderboardRepository {
  Future<List<LeaderboardEntry>> topScores(GameMode mode);
  Future<int> submitAttempt(VerifiedAttempt attempt);
}

abstract interface class AuthService {
  Future<String> signInAnonymously();
  Future<String?> currentUsername();
  Future<String> claimUsername(String username);
}

abstract interface class EntitlementService {
  Future<bool> get hasPro;
}

abstract interface class AdService {
  bool get isEnabled;
  Future<bool> initialize();
  Future<void> showPostGameAd();
  Future<bool> showRewardedHint(FutureOr<void> Function() onReward);
  Future<bool> showPrivacyOptions();
  void dispose();
}

abstract interface class AnalyticsService {
  Future<void> capture(
    String event, [
    Map<String, Object?> properties = const {},
  ]);
}

abstract interface class NotificationScheduler {
  Future<void> scheduleDailyReminder();
  Future<void> cancelDailyReminder();
}

class LeaderboardEntry {
  const LeaderboardEntry({required this.username, required this.score});

  final String username;
  final int score;
}

class VerifiedAttempt {
  const VerifiedAttempt({
    required this.puzzleId,
    required this.mode,
    required this.guesses,
    required this.startedAt,
    required this.completedAt,
  });

  final String puzzleId;
  final GameMode mode;
  final List<String> guesses;
  final DateTime startedAt;
  final DateTime completedAt;
}

class DisabledServices
    implements
        LeaderboardRepository,
        AuthService,
        EntitlementService,
        AdService,
        AnalyticsService,
        NotificationScheduler {
  const DisabledServices();

  @override
  Future<void> capture(
    String event, [
    Map<String, Object?> properties = const {},
  ]) async {}

  @override
  Future<void> cancelDailyReminder() async {}

  @override
  Future<bool> get hasPro async => false;

  @override
  bool get isEnabled => false;

  @override
  Future<bool> initialize() async => false;

  @override
  Future<void> scheduleDailyReminder() async {}

  @override
  Future<void> showPostGameAd() async {}

  @override
  Future<bool> showPrivacyOptions() async => false;

  @override
  Future<bool> showRewardedHint(FutureOr<void> Function() onReward) async =>
      false;

  @override
  void dispose() {}

  @override
  Future<String> claimUsername(String username) =>
      Future.error(StateError('Online services are disabled.'));

  @override
  Future<String?> currentUsername() async => null;

  @override
  Future<String> signInAnonymously() =>
      Future.error(StateError('Online services are disabled.'));

  @override
  Future<int> submitAttempt(VerifiedAttempt attempt) =>
      Future.error(StateError('Leaderboards are disabled.'));

  @override
  Future<List<LeaderboardEntry>> topScores(GameMode mode) async => const [];
}
