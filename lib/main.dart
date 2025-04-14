import 'package:flutter/material.dart';
import 'package:uklivetrains/nav.dart';
import 'package:uklivetrains/pages/routes/settings/lightdarkmode.dart';
import 'package:uklivetrains/structs/themenotifier.dart';
import 'package:uklivetrains/themes/themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemePairNotifier? _themePairNotifier;
  ThemeMode? _themeMode;
  //ThemeNotifier? _themeNotifierDark;
  // ThemeData? _themeDataLight;
  // ThemeData? _themeDataDark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadLightDarkPreference();
  }

  Future<void> _loadTheme() async {
    // TODO: remove inefficiencies here if the app does not support different colour themes for light and dark selected indepedently
    ThemeData themeDataLight = await fetchSavedTheme();
    ThemeData themeDataDark = await fetchSavedTheme(isDarkTheme: true);
    _themePairNotifier = ThemePairNotifier(ThemePair(themeDataLight, themeDataDark));
    //ThemeData? _themeDataDark = await fetchSavedTheme(isDarkTheme: true);
    setState(() {});
  }

  Future<void> _loadLightDarkPreference() async {
    ThemePreference themePreference = await fetchSavedLightDarkThemePreference();
    // Convert between the program-defined ThemePreference enum, and the flutter-defined ThemeMode enum
    Map<ThemePreference, ThemeMode> enumConvert = {
      ThemePreference.dark:ThemeMode.dark,
      ThemePreference.light:ThemeMode.light,
      ThemePreference.system:ThemeMode.system,
    };
    setState(() {
      _themeMode = enumConvert[themePreference];
      print("Launching with light/dark/system theme mode: $_themeMode");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_themePairNotifier != null) {
      return ValueListenableBuilder<ThemePair>(
          valueListenable: _themePairNotifier!, // if light changes, so will dark
          builder: (context, themePair, _) {
            return MaterialApp(
              title: 'Live Trains',
              theme: themePair.lightTheme,
              darkTheme: themePair.darkTheme, //hemePair.darkTheme, ThemeData.dark(), theme.copyWith(textTheme: Typography.material2021().white, brightness: Brightness.dark), theme.copyWith(brightness: Brightness.dark)
              themeMode: _themeMode,
              home: NavPartialPage(themeNotifier: _themePairNotifier!),
            );
          });
    } else {
      return MaterialApp(
        title: 'Live Trains',
        theme: DEFAULT_THEME_DATA,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}
