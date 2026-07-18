import 'package:flutter/material.dart';
import 'package:verdict/app/brutal_widgets.dart';
import 'package:verdict/features/settings/app_settings.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    required this.settings,
    required this.onHighContrastChanged,
    super.key,
  });

  final AppSettings settings;
  final ValueChanged<bool> onHighContrastChanged;

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _highContrast = widget.settings.highContrast;

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
          ],
        ),
      ),
    ),
  );
}
