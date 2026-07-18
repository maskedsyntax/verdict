class AppSettings {
  const AppSettings({this.highContrast = false});

  final bool highContrast;

  AppSettings copyWith({bool? highContrast}) =>
      AppSettings(highContrast: highContrast ?? this.highContrast);

  Map<String, Object?> toJson() => {'highContrast': highContrast};

  factory AppSettings.fromJson(Map<String, Object?> json) =>
      AppSettings(highContrast: json['highContrast'] as bool? ?? false);
}
