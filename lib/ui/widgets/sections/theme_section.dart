import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/color_choice_chip.dart';
import 'package:characterbook/ui/widgets/sections/settings_section.dart';
import 'package:characterbook/ui/widgets/theme_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:characterbook/providers/theme_provider.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final s = S.of(context);
    final accentColors = {
      s.blue: Colors.blue,
      s.green: Colors.green,
      s.red: Colors.red,
      s.orange: Colors.orange,
      s.purple: Colors.purple,
      s.pink: Colors.pink,
      s.teal: Colors.teal,
      s.lightBlue: Colors.lightBlue,
    };

    return SettingsSection(
      title: s.theme,
      children: [
        const _ThemeModeSelector(),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _AccentColorTitle(s: s),
        const SizedBox(height: 12),
        _AccentColorSelector(themeProvider: themeProvider, accentColors: accentColors),
      ],
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final s = S.of(context);

    return Column(
      children: [
        ThemeListTile(
          themeProvider: themeProvider,
          mode: ThemeMode.system,
          title: s.system,
          icon: Icons.phone_android,
        ),
        ThemeListTile(
          themeProvider: themeProvider,
          mode: ThemeMode.light,
          title: s.light,
          icon: Icons.light_mode,
        ),
        ThemeListTile(
          themeProvider: themeProvider,
          mode: ThemeMode.dark,
          title: s.dark,
          icon: Icons.dark_mode,
        ),
      ],
    );
  }
}

class _AccentColorTitle extends StatelessWidget {
  final S s;

  const _AccentColorTitle({required this.s});

  @override
  Widget build(BuildContext context) {
    return Text(
      s.accentColor.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _AccentColorSelector extends StatelessWidget {
  final ThemeProvider themeProvider;
  final Map<String, Color> accentColors;

  const _AccentColorSelector({
    required this.themeProvider,
    required this.accentColors,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: accentColors.entries.map((entry) => ColorChoiceChip(
        themeProvider: themeProvider,
        label: entry.key,
        color: entry.value,
      )).toList(),
    );
  }
}