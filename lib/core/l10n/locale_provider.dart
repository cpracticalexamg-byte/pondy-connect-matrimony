import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefLocaleKey = 'app_locale_code';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefLocaleKey);
    if (code != null && (code == 'en' || code == 'ta')) {
      state = Locale(code);
    }
  }

  Future<void> toggleLocale() async {
    final newCode = state.languageCode == 'en' ? 'ta' : 'en';
    state = Locale(newCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLocaleKey, newCode);
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'ta') return;
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLocaleKey, languageCode);
  }
}
