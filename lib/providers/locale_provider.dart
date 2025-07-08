import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:characterbook/generated/l10n.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  LocaleProvider() {
    _loadPreferences();
  }

  Locale get locale => _locale ?? S.delegate.supportedLocales.first;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('selectedLocale');
    
    if (localeCode != null && localeCode.isNotEmpty) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!S.delegate.supportedLocales.contains(newLocale)) return;
    
    _locale = newLocale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLocale', newLocale.languageCode);
  }
}