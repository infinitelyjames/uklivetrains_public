import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/persistentdata.dart';
import 'package:uklivetrains/pages/routes/settings/lightdarkmode.dart';

const String THEME_STORAGE_KEY = "theme";

var DEFAULT_THEME_DATA = ThemeData(
  // This is the theme of your application.
  colorScheme: ColorScheme.fromSeed(
      seedColor:
          DEFAULT_THEME_COLOR), // cool looking colors: Color.fromARGB(255, 183, 66, 58), Color.fromARGB(255, 58, 183, 79), olor.fromARGB(255, 58, 183,183), Color.fromARGB(255, 183, 108,58)
  useMaterial3: true,
);

/* 
Determines if the theme is for light mode, dark mode, or both (not necessarily supported)
*/
enum ThemeUsage {
  light,
  dark,
  both,
}

class CompleteAppTheme {
  final ThemeData flutterAppTheme;
  final String? backgroundImagePath;
  final String themeName;
  final ThemeUsage themeUsage;

  CompleteAppTheme({
    required this.flutterAppTheme,
    this.backgroundImagePath,
    required this.themeName,
    this.themeUsage = ThemeUsage.light,
  });

  Color getBackgroundColor() {
    return flutterAppTheme.primaryColor.withOpacity(0.1);
  }

  List<Widget> getBackgroundStackList() {
    List<Widget> widgets = backgroundImagePath != null
        ? // Background image
        [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(backgroundImagePath!, fit: BoxFit.cover),
              ),
            )
          ]
        : [];
    widgets.add(Positioned.fill(
        child: Container(
      color: getBackgroundColor(),
    )));
    return widgets;
  }
}

class SerializedCompleteAppTheme with Serializable {
  late final CompleteAppTheme completeAppTheme;

  SerializedCompleteAppTheme({CompleteAppTheme? completeAppTheme}) {
    if (completeAppTheme == null) {
      redundantClass = true;
    } else {
      redundantClass = false;
      this.completeAppTheme = completeAppTheme;
    }
  }

  @override
  String toJSON() {
    protectInstantiationIntegrity();
    return jsonEncode({
      // App themes are generated from seed, which is stored as the primaryColor
      // Note: if any details about the themes are modified from the fromSeed(...), they must be stored here
      "color": {
        "r": completeAppTheme.flutterAppTheme.primaryColor.red,
        "g": completeAppTheme.flutterAppTheme.primaryColor.green,
        "b": completeAppTheme.flutterAppTheme.primaryColor.blue,
        "a": completeAppTheme.flutterAppTheme.primaryColor.alpha,
      },
      "backgroundImagePath": completeAppTheme.backgroundImagePath,
      // name needs to be stored so we can show the user what they have actually selected
      "name": completeAppTheme.themeName,
      "usage": completeAppTheme.themeUsage,
    });
  }

  @override
  fromJSON(String rawData) {
    // TODO: implement fromJSON
    throw UnimplementedError();
  }
}

TextTheme cloneTextTheme(TextTheme original) {
  return TextTheme(
    displayLarge: original.displayLarge!.copyWith(inherit: false),
    displayMedium: original.displayMedium!.copyWith(inherit: false),
    displaySmall: original.displaySmall!.copyWith(inherit: false),
    headlineLarge: original.headlineLarge!.copyWith(inherit: false),
    headlineMedium: original.headlineMedium!.copyWith(inherit: false),
    headlineSmall: original.headlineSmall!.copyWith(inherit: false),
    titleLarge: original.titleLarge!.copyWith(inherit: false),
    titleMedium: original.titleMedium!.copyWith(inherit: false),
    titleSmall: original.titleSmall!.copyWith(inherit: false),
    bodyLarge: original.bodyLarge!.copyWith(inherit: false),
    bodyMedium: original.bodyMedium!.copyWith(inherit: false),
    bodySmall: original.bodySmall!.copyWith(inherit: false),
    labelLarge: original.labelLarge!.copyWith(inherit: false),
    labelMedium: original.labelMedium!.copyWith(inherit: false),
    labelSmall: original.labelSmall!.copyWith(inherit: false),
  );
}

ThemeData themeFromSeed(Color color, {bool isDarkTheme = false}) {
  //print("Theme1: ${Typography.material2021().black.displayLarge!.fontSize}");
  return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color, 
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),
      textTheme: isDarkTheme
          ? Typography.material2021().white
          : Typography.material2021().black,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      useMaterial3: true);
}

// TODO - generate background images
final List<CompleteAppTheme> INBUILT_APP_THEMES = [
  CompleteAppTheme(
      flutterAppTheme: themeFromSeed(Colors.deepPurple),
      themeName: "Network Purple",
      backgroundImagePath: "assets/background1.jpeg"),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Colors.red),
    themeName: "Crimson Red",
    backgroundImagePath: "assets/background1.jpeg",
  ),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Colors.blue),
    themeName: "Ocean Blue",
    backgroundImagePath: "assets/background1.jpeg",
  ),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Colors.green),
    themeName: "Forest Green",
    backgroundImagePath: "assets/background1.jpeg",
  ),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Colors.yellow),
    themeName: "Amber Dawn",
    backgroundImagePath: "assets/background1.jpeg",
  ),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Colors.pink),
    themeName: "Ruby Radiance",
    backgroundImagePath: "assets/background1.jpeg",
  ),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Color.fromARGB(255, 88, 88, 88)),
    themeName: "Slate Serenity",
    backgroundImagePath: "assets/background1.jpeg",
  ),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Colors.lightBlue),
    themeName: "Seafoam Mist",
    backgroundImagePath: "assets/background1.jpeg",
  ),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Colors.orange),
    themeName: "Sunset Coral",
    backgroundImagePath: "assets/background1.jpeg",
  ),
  CompleteAppTheme(
    flutterAppTheme: themeFromSeed(Color.fromRGBO(85, 57, 204, 1)),
    themeName: "Royal Twilight",
    backgroundImagePath: "assets/background1.jpeg",
  ),
];

Future<ThemeData> fetchSavedTheme({bool isDarkTheme = false}) async {
  try {
    return themeFromSeed(await ThemeColor.fetchThemeColor(),
        isDarkTheme: isDarkTheme);
  } catch (e) {
    print("Fatal exception occurred when attempting to load theme data: $e");
    return DEFAULT_THEME_DATA;
  }
}

Future<ThemePreference> fetchSavedLightDarkThemePreference() async {
  try {
    return (await LightDarkThemeDataSerializable.loadSaved()).themePreference;
  } catch (e) {
    print("An error occurred when fetching saved light dark theme preference, therefore the system option has been returned by default: \n$e");
    return ThemePreference.system;
  }
}

Future<void> setThemeColor(Color color) async {
  await ThemeColor.setThemeColor(color);
}

void main() {
  print(
      "Theme 4: ${INBUILT_APP_THEMES[0].flutterAppTheme.textTheme.displayLarge}");
}
