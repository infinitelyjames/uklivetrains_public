import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/persistentdata.dart';
import 'package:uklivetrains/structs/themenotifier.dart';
import 'package:uklivetrains/themes/themes.dart';

class ThemeDemoPage extends StatelessWidget {
  final CompleteAppTheme theme;
  final ThemePairNotifier themeNotifier;

  ThemeDemoPage({super.key, required this.theme, required this.themeNotifier});

  void _onPlaceholderButtonTap(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("This is a placeholder")));
  }

  @Deprecated("Currently deprecated awaiting more centralised theming")
  Future<void> _setThemeColor(BuildContext context) async {
    //print("Setting theme color");
    // Live update the color in the app
    themeNotifier
        .updateTheme(ThemePair(themeFromSeed(theme.flutterAppTheme.primaryColor), themeFromSeed(theme.flutterAppTheme.primaryColor, isDarkTheme: true)));
    // Exit the theme viewer
    Navigator.pop(context);
    // Save persistently in the background
    await ThemeColor.setThemeColor(theme.flutterAppTheme.primaryColor);
  }

  // TODO - replace example widgets with those fetced directly from relevant pages to avoid code duplication and loss of integrity
  @override
  Widget build(BuildContext context) {
    //print("Theme1b: ${Theme.of(context).textTheme.displayLarge}");
    //print("Theme2: ${theme.flutterAppTheme.textTheme.displayLarge}");
    return Theme(
        data: theme.flutterAppTheme,
        child: Scaffold(
          appBar: AppBar(
            title: Text(theme.themeName),
            automaticallyImplyLeading: false,
            backgroundColor: theme.flutterAppTheme.colorScheme.inversePrimary,
          ),
          body: Stack(
            children: [
              ...theme.getBackgroundStackList(),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _onPlaceholderButtonTap(context),
                      label: Text("Search"),
                      icon: Icon(Icons.search),
                    ),
                    FilledButton.tonal(
                        onPressed: () => _onPlaceholderButtonTap(context),
                        child: Text("Less important button")),
                    Container(
                      child: Text("Highlighted text box"),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(228, 228, 228, 0.686),
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: theme.flutterAppTheme.primaryColor,
                            width: 2),
                      ),
                      padding: EdgeInsets.all(8),
                    ),
                    Container(
                      child: Text("Less important text box"),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(228, 228, 228, 0.5),
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: theme
                                .flutterAppTheme.colorScheme.inversePrimary,
                            width: 2),
                      ),
                      padding: EdgeInsets.all(8),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(228, 228, 228, 0.686),
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: theme.flutterAppTheme.primaryColor,
                            width: 2),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            "displayLarge",
                            style: theme.flutterAppTheme.textTheme.displayLarge,
                          ),
                          Text(
                            "titleMedium",
                            style: theme.flutterAppTheme.textTheme.titleMedium,
                          ),
                          Text(
                            "bodyLarge",
                            style: theme.flutterAppTheme.textTheme.bodyLarge,
                          ),
                          Text(
                            "bodyMedium",
                            style: theme.flutterAppTheme.textTheme.bodyMedium,
                          ),
                          Text(
                            "bodySmall",
                            style: theme.flutterAppTheme.textTheme.bodySmall,
                          ),
                          Text(
                            "displayLarge",
                            style: theme.flutterAppTheme.textTheme.displayLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _setThemeColor(context),
            child: Icon(Icons.check_rounded),
            tooltip: "Select",
          ),
        ));
  }
}
