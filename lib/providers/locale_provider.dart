import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('sw'); // Default to Swahili for Tanzanian VICOBA domain

  Locale get locale => _locale;
  bool get isSwahili => _locale.languageCode == 'sw';

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('vicoba_locale_code');
    if (savedCode != null) {
      _locale = Locale(savedCode);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale loc) async {
    if (_locale == loc) return;
    _locale = loc;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vicoba_locale_code', loc.languageCode);
  }

  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'sw') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('sw'));
    }
  }
}
