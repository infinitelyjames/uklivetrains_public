import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uklivetrains/pages/routes/settings/lightdarkmode.dart';
import 'package:uklivetrains/structs/departureboardquerytimed.dart';
import 'package:uklivetrains/structs/homescreenwidgetdetails.dart';
import 'package:uklivetrains/structs/stationboardquery.dart';

@Deprecated("Store the entire theme instead of just a theme color")
const String THEME_COLOR_STORAGE_KEY = "themecolor";
@Deprecated("Store the entire theme instead of just a theme color")
const Color DEFAULT_THEME_COLOR = Colors.deepPurple;
const String STATION_BOARD_QUERY_LIST_STORAGE_KEY = "stationboardqueries";
const String HOME_PAGE_WIDGETS_STORAGE_KEY = "homepagewidgets";
const String LIGHT_DARK_THEME_DATA_STORAGE_KEY = "lightdarktheme";

/* Important notes when implementing serializable:
- Configure constructor to correctly set redundant class flag
- Call protectInstantiationIntegrity from every class that uses data stored in attributes

mixin is used to allow a method body to be supplied for protectInstant... without needing for it to be overriden in subclasses (would be required if the class was abstract)
*/
class ImproperlyInstantiatedException implements Exception {
  final String message;

  ImproperlyInstantiatedException(this.message);

  @override
  String toString() => 'ImproperlyInstantiatedException: $message';
}

mixin Serializable<T> {
  late final bool redundantClass;
  String toJSON();
  T fromJSON(String rawData);

  void protectInstantiationIntegrity() {
    if (redundantClass) {
      throw ImproperlyInstantiatedException(
          "Cannot retrieve data if class is instantiated with no intent for non-static methods");
    }
  } // prevents access to fake static methods if not instantiated with data
}

class PersistentDataModifier {
  SharedPreferences? prefs;

  Future<void> initialiseSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> initialiseIfNotAlready() async {
    if (prefs == null) await initialiseSharedPrefs();
  }

  Future<void> setRawStringData(String key, String serializedJSON) async {
    await initialiseIfNotAlready();
    prefs!.setString(key, serializedJSON);
  }

  // Stores the serializable object for future retrieval
  Future<void> setObject<T extends Serializable>(String key, T object) async {
    await setRawStringData(key, object.toJSON());
  }

  Future<String?> retrieveRawStringData(String key) async {
    await initialiseIfNotAlready();
    return prefs!.getString(key);
  }

  // Retrieves a serialised saved object. A blank Serialized object must be supplied
  Future<T?> retrieveSerializedObject<T extends Serializable>(
      String key, T blankObject) async {
    String? rawData = await retrieveRawStringData(key);
    if (rawData == null) return null;
    return blankObject.fromJSON(rawData);
  }
}

@Deprecated("Store the entire theme instead of just a theme color")
class ThemeColor with Serializable {
  late final Color seedColor;

  ThemeColor({Color? seedColor}) {
    if (seedColor == null) {
      redundantClass = true;
    } else {
      redundantClass = false;
      this.seedColor = seedColor;
    }
  }

  @override
  String toJSON() {
    protectInstantiationIntegrity();
    return jsonEncode({
      "r": seedColor.red,
      "g": seedColor.green,
      "b": seedColor.blue,
      "a": seedColor.alpha
    });
  }

  @override
  ThemeColor fromJSON(String rawData) {
    //print("RawData: $rawData");
    Map<String, dynamic> json = jsonDecode(rawData);
    if (json["a"] == null ||
        json["r"] == null ||
        json["g"] == null ||
        json["b"] == null) {
      throw ArgumentError.notNull("JSON must contain a, r, g, b keys");
    }
    Color color = Color.fromARGB(json["a"], json["r"], json["g"], json["b"]);
    return ThemeColor(seedColor: color);
  }

  static Future<Color> fetchThemeColor() async {
    PersistentDataModifier modifier = PersistentDataModifier();
    ThemeColor temp = ThemeColor();
    ThemeColor? result = await modifier.retrieveSerializedObject<ThemeColor>(
        THEME_COLOR_STORAGE_KEY, temp);
    if (result == null) return DEFAULT_THEME_COLOR;
    return result.seedColor;
  }

  static Future<void> setThemeColor(Color newColor) async {
    PersistentDataModifier modifier = PersistentDataModifier();
    ThemeColor newThemeColor = ThemeColor(seedColor: newColor);
    await modifier.setObject(THEME_COLOR_STORAGE_KEY, newThemeColor);
  }
}

/* 
This stores whether the light, dark, or system theme should be used.
If system is selected, it follows whichever of light or dark is selected at that time.
The theme of the app should also update should the system theme change during app use (ie. if it is scheduled)

IMPORTANT NOTE:
- This function does NOT store using JSON
*/
class LightDarkThemeDataSerializable {
  ThemePreference themePreference; // Light, dark, or system

  LightDarkThemeDataSerializable({required this.themePreference});

  factory LightDarkThemeDataSerializable.fromRAW(String rawData) {
    return LightDarkThemeDataSerializable(themePreference: ThemePreference.values.firstWhere((theme) => theme.toString() == rawData, orElse: () => ThemePreference.system));
  }

  static Future<LightDarkThemeDataSerializable> loadSaved() async {
    PersistentDataModifier persistentDataModifier = PersistentDataModifier();
    String? rawData = await persistentDataModifier.retrieveRawStringData(LIGHT_DARK_THEME_DATA_STORAGE_KEY);
    if (rawData == null) {
      print("WARN: no data found saved persistently for LightDarkThemeSerializable, returning system as default");
      return LightDarkThemeDataSerializable(themePreference: ThemePreference.system);
    }
    return LightDarkThemeDataSerializable.fromRAW(rawData);
  }

  String toRAW() {
    return themePreference.toString();
  }

  Future<void> savePersistent() async {
    PersistentDataModifier persistentDataModifier = PersistentDataModifier();
    await persistentDataModifier.setRawStringData(LIGHT_DARK_THEME_DATA_STORAGE_KEY, toRAW());
  }
}

// These are the starred station boards which show up on the live trains search page.
class StarredStationBoardsListSerializable {
  List<StationBoardQuery> boardQueryList;

  StarredStationBoardsListSerializable({required this.boardQueryList});

  // Load from persistent storage on the disk
  static Future<StarredStationBoardsListSerializable> loadSaved() async {
    PersistentDataModifier persistentDataModifier = PersistentDataModifier();
    String? json = await persistentDataModifier
        .retrieveRawStringData(STATION_BOARD_QUERY_LIST_STORAGE_KEY);
    // Return a blank copy, not null if nothing found
    if (json == null) {
      print("Warning: no starred station board data found saved persistently, returning empty list");
      return StarredStationBoardsListSerializable(boardQueryList: []);
    }
    return StarredStationBoardsListSerializable.fromJSON(jsonDecode(json));
  }

  // Update the persistent copy with the contents of this class
  Future<void> savePersistent() async {
    PersistentDataModifier persistentDataModifier = PersistentDataModifier();
    await persistentDataModifier.setRawStringData(
        STATION_BOARD_QUERY_LIST_STORAGE_KEY, jsonEncode(toJSON()));
  }

  factory StarredStationBoardsListSerializable.fromJSON(List<dynamic> json) {
    List<StationBoardQuery> boardQueries = [];
    for (var boardQuery in json) {
      boardQueries.add(StationBoardQuery.fromJSON(boardQuery));
    }
    return StarredStationBoardsListSerializable(boardQueryList: boardQueries);
  }

  List<dynamic> toJSON() {
    List queries = [];
    for (StationBoardQuery boardQuery in boardQueryList) {
      queries.add(boardQuery.toJSON());
    }
    return queries;
  }
}

// A list of the details for departure board widgets to show on the home screen (at specific times etc)
class HomeScreenWidgetsListSerializable {
  List<HomeScreenWidgetDetails> widgets;

  HomeScreenWidgetsListSerializable({required this.widgets});

  factory HomeScreenWidgetsListSerializable.fromJSON(
      List<Map<String, dynamic>> json) {
    return HomeScreenWidgetsListSerializable(
        widgets: json
            .map((Map<String, dynamic> jsonObject) =>
                jsonObjectMapper(jsonObject))
            .toList());
  }

  // factory
  static Future<HomeScreenWidgetsListSerializable> loadSaved() async {
    PersistentDataModifier persistentDataModifier = PersistentDataModifier();
    String? json = await persistentDataModifier
        .retrieveRawStringData(HOME_PAGE_WIDGETS_STORAGE_KEY);
    if (json == null) {
      print("Warning: no saved (persistent) home screen widget data found");
      return HomeScreenWidgetsListSerializable(widgets: []);
    }
    print("Retrieved json: $json");
    List<dynamic> jsonDecodedUncasted = jsonDecode(json);
    List<Map<String, dynamic>> jsonDecoded =
        List<Map<String, dynamic>>.from(jsonDecodedUncasted);
    return HomeScreenWidgetsListSerializable.fromJSON(jsonDecoded);
  }

  static HomeScreenWidgetDetails jsonObjectMapper(
      Map<String, dynamic> jsonWidgetDetails) {
    if (jsonWidgetDetails["widgetType"] == DEPARTURE_BOARD_WIDGET_TYPE) {
      return DepartureBoardQueryTimed.fromJSON(jsonWidgetDetails);
    } else {
      throw Exception("Widget type not found");
    }
  }

  List<dynamic> toJSON() {
    return widgets.map((widget) => widget.toJSON()).toList();
  }

  Future<void> savePersistent() async {
    PersistentDataModifier persistentDataModifier = PersistentDataModifier();
    print("JSON: ${toJSON()}");
    await persistentDataModifier.setRawStringData(
        HOME_PAGE_WIDGETS_STORAGE_KEY, jsonEncode(toJSON()));
  }
}
