class AppSettings {
  const AppSettings({this.highContrast = false, this.streakReminder = false});

  final bool highContrast;
  final bool streakReminder;

  AppSettings copyWith({bool? highContrast, bool? streakReminder}) =>
      AppSettings(
        highContrast: highContrast ?? this.highContrast,
        streakReminder: streakReminder ?? this.streakReminder,
      );

  Map<String, Object?> toJson() => {
    'highContrast': highContrast,
    'streakReminder': streakReminder,
  };

  factory AppSettings.fromJson(Map<String, Object?> json) => AppSettings(
    highContrast: json['highContrast'] as bool? ?? false,
    streakReminder: json['streakReminder'] as bool? ?? false,
  );
}
