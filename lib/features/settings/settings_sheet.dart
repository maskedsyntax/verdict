import 'package:flutter/material.dart';
import 'package:verdict/app/brutal_widgets.dart';
import 'package:verdict/features/settings/app_settings.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    required this.settings,
    required this.onHighContrastChanged,
    required this.onStreakReminderChanged,
    this.onAdPrivacy,
    super.key,
  });

  final AppSettings settings;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onStreakReminderChanged;
  final VoidCallback? onAdPrivacy;

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _highContrast = widget.settings.highContrast;
  late bool _streakReminder = widget.settings.streakReminder;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 21, 20),
      child: BrutalBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SETTINGS',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close settings',
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'HIGH CONTRAST',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('Stronger tile and keyboard colors'),
              value: _highContrast,
              onChanged: (enabled) {
                setState(() => _highContrast = enabled);
                widget.onHighContrastChanged(enabled);
              },
            ),
            if (widget.onAdPrivacy != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'AD PRIVACY',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Review advertising consent choices'),
                trailing: const Icon(Icons.privacy_tip_outlined),
                onTap: widget.onAdPrivacy,
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'STREAK REMINDER',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('Notify me before today\'s puzzle expires'),
              value: _streakReminder,
              onChanged: (enabled) {
                setState(() => _streakReminder = enabled);
                widget.onStreakReminderChanged(enabled);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
