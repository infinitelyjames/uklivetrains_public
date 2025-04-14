import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/persistentdata.dart';
import 'package:uklivetrains/pages/routes/about.dart';
import 'package:uklivetrains/pages/routes/settings/homewidgets.dart';
import 'package:uklivetrains/pages/routes/settings/lightdarkmode.dart';
import 'package:uklivetrains/pages/routes/settings/themes/themeselector.dart';
import 'package:uklivetrains/structs/themenotifier.dart';
import 'package:uklivetrains/themes/themes.dart';
import 'package:uklivetrains/widgets/settings/settingscategorycontainer.dart';
import 'package:uklivetrains/widgets/settings/settingslink.dart';
import 'package:url_launcher/url_launcher.dart';

const Map<String, Color> COLOR_MAP = {
  "red": Colors.red,
  "blue": Colors.blue,
  "purple": Colors.deepPurple,
};

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.themeNotifier});
  final ThemePairNotifier themeNotifier;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _setThemeColor(Color color) async {
    widget.themeNotifier.updateTheme(ThemePair(themeFromSeed(color), themeFromSeed(color, isDarkTheme: true)));
    await ThemeColor.setThemeColor(color);
  }

  void _onThemeSelected(String? value) {
    if (value == null) return;
    _setThemeColor(COLOR_MAP[value] ?? Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text("Theme", style: Theme.of(context).textTheme.titleMedium),
        //     Text("Select an app colour theme that best suits you",
        //         style: Theme.of(context).textTheme.bodyMedium),
        //     DropdownMenu(
        //       dropdownMenuEntries: [
        //         DropdownMenuEntry(value: "red", label: "Red"),
        //         DropdownMenuEntry(value: "purple", label: "Purple"),
        //         DropdownMenuEntry(value: "blue", label: "Blue")
        //       ],
        //       initialSelection: "red",
        //       onSelected: (value) => _onThemeSelected(value),
        //     ),
        //     FilledButton.tonal(
        //         onPressed: () => Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => ThemeSelectionPage())),
        //         child: Text("Try out light themes"))
        //   ],
        // ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text("Time format", style: Theme.of(context).textTheme.titleMedium),
        //     const DropdownMenu(
        //       dropdownMenuEntries: [
        //         DropdownMenuEntry(value: "24", label: "24 Hour"),
        //         DropdownMenuEntry(value: "12", label: "12 Hour")
        //       ],
        //       initialSelection: "24",
        //     )
        //   ],
        // ),
        // FilledButton.tonal(
        //   onPressed: () => showAboutDialog(
        //     context: context,
        //     applicationVersion:
        //         "v1", // TODO - implement using https://pub.dev/packages/package_info_plus (installed)
        //     applicationIcon: SizedBox(
        //       child: Image.asset("assets/icon/icon.png"),
        //       width: 60,
        //       height: 60,
        //     ),
        //   ),
        //   child: const Text("About"),
        // ),
        SettingsCategoryContainer(
          categoryName: "General",
          settingsActionWidgets: [
            SettingsLinkWidget(
              icon: Icon(Icons.home),
              title: "Home",
              subtitle: "Select widgets to appear",
              onTapCallback: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeWidgetsRoute())),
            ),
            SettingsLinkWidget(
              icon: Icon(Icons.feed),
              title: "Data Feeds",
              subtitle: "Trainspotter mode",
            ),
            SettingsLinkWidget(
              icon: Icon(Icons.notifications),
              title: "Active Alerts",
              subtitle: "Train tracker notifications",
            ),
          ],
        ),
        const SizedBox(height: 5),
        SettingsCategoryContainer(
          categoryName: "Appearance",
          settingsActionWidgets: [
            SettingsLinkWidget(
              icon: Icon(Icons.brush),
              title: "Colour Theme",
              onTapCallback: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ThemeSelectionPage(
                            themeNotifier: widget.themeNotifier,
                          ))),
            ),
            SettingsLinkWidget(
                icon: Icon(Icons.light_mode), 
                title: "Light & Dark Modes",
                onTapCallback: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LightModeDarkModeSettingsPage())),
                ),
            SettingsLinkWidget(icon: Icon(Icons.zoom_in_sharp), title: "Zoom"),
            SettingsLinkWidget(icon: Icon(Icons.abc), title: "Font"),
          ],
        ),
        const SizedBox(height: 5),
        SettingsCategoryContainer(
          categoryName: "Time & Date",
          settingsActionWidgets: [
            SettingsLinkWidget(
                icon: Icon(Icons.alarm), title: "24/12 hour time"),
            SettingsLinkWidget(
                icon: Icon(Icons.calendar_month_rounded), title: "Date format"),
          ],
        ),
        const SizedBox(height: 5),
        SettingsCategoryContainer(
          categoryName: "App Information",
          settingsActionWidgets: [
            SettingsLinkWidget(
              icon: Icon(Icons.info),
              title: "About",
              onTapCallback: () => showAboutDialog(
                context: context,
                applicationVersion:
                    "v1", // TODO - implement using https://pub.dev/packages/package_info_plus (installed)
                applicationIcon: SizedBox(
                  child: Image.asset("assets/icon/icon.png"),
                  width: 60,
                  height: 60,
                ),
              ),
            ),
            SettingsLinkWidget(icon: Icon(Icons.history), title: "Changelog"),
            SettingsLinkWidget(
                icon: Icon(Icons.chat),
                title: "Support",
                onTapCallback: () => launchUrl(
                    Uri.parse("https://infinitydev.org.uk/#socials"))),
            SettingsLinkWidget(
                icon: Icon(Icons.link),
                title: "Website",
                onTapCallback: () =>
                    launchUrl(Uri.parse("http://infinitydev.org.uk"))),
            SettingsLinkWidget(
                icon: Icon(Icons.monetization_on),
                title: "Donate",
                onTapCallback: () => launchUrl(Uri.parse(
                    "http://infinitydev.org.uk"))), // TODO: add correct link
          ],
        ),
        SettingsCategoryContainer(categoryName: "Developer Options", settingsActionWidgets: [
          SettingsLinkWidget(icon: Icon(Icons.code_rounded), title: "Print debugging information", onTapCallback: () {
            print("Theme type: ${Theme.of(context).brightness}");
          },)
        ]),
      ],
    );
  }
}
