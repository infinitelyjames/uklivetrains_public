import 'package:flutter/material.dart';

/* 
Use this when you are dealing with a single type of theme only - ie. light or dark
*/
@Deprecated("No longer used, will be removed in a future release")
class ThemeNotifier extends ValueNotifier<ThemeData> {
  ThemeNotifier(ThemeData value) : super(value);

  void updateTheme(ThemeData newTheme) {
    value = newTheme;
  }
}

class ThemePair {
  ThemeData lightTheme;
  ThemeData darkTheme;

  ThemePair(this.lightTheme, this.darkTheme);
}

/* 
Use this when you are dealing with both light and dark themes - 
*/
class ThemePairNotifier extends ValueNotifier<ThemePair> {
  ThemePairNotifier(ThemePair pair) : super(pair);

  void updateTheme(ThemePair newThemePair) {
    value = newThemePair;
  }
}
