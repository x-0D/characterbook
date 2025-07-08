import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/sections/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:characterbook/providers/locale_provider.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    
    return SettingsSection(
      title: s.appLanguage,
      children: const [_LanguageSelector()],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(s.language),
      trailing: DropdownButton<Locale>(
        value: localeProvider.locale,
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            localeProvider.setLocale(newLocale);
          }
        },
        items: S.delegate.supportedLocales.map((Locale locale) {
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Text(
              _displayName(locale),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }).toList(),
        underline: Container(),
        borderRadius: BorderRadius.circular(12),
        dropdownColor: colorScheme.surfaceContainerHigh,
        icon: Icon(
          Icons.arrow_drop_down,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

String _displayName(Locale locale) {
  switch (locale.languageCode) {
    case 'ru': return 'Русский';
    case 'en': return 'English';
    default: return locale.languageCode;
  }
}