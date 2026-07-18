import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdict/core/services/future_services.dart';

const _disabledServices = DisabledServices();

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => _disabledServices,
);

final authServiceProvider = Provider<AuthService>((ref) => _disabledServices);

final onlineServicesEnabledProvider = Provider<bool>((ref) => false);
