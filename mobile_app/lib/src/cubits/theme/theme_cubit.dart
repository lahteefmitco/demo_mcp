import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/app_preferences_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required AppPreferencesStorage preferencesStorage})
    : _preferencesStorage = preferencesStorage,
      super(ThemeMode.system);

  final AppPreferencesStorage _preferencesStorage;

  Future<void> loadTheme() async {
    final modeStr = await _preferencesStorage.readThemeMode();
    if (modeStr == 'light') {
      emit(ThemeMode.light);
    } else if (modeStr == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
    }
    await _preferencesStorage.writeThemeMode(modeStr);
    emit(mode);
  }
}
