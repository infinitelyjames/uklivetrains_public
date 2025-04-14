import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:uklivetrains/pages/routes/settings/themes/themedemo.dart';
import 'package:uklivetrains/structs/themenotifier.dart';
import 'package:uklivetrains/themes/themes.dart';

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key, required this.themeNotifier});
  final ThemePairNotifier themeNotifier;
  @override
  State<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  final PageController _controller = PageController();
  List<ThemeDemoPage> _themePages = [];

  void _setThemePages() {
    List<ThemeDemoPage> pages = [];
    for (CompleteAppTheme appTheme in INBUILT_APP_THEMES) {
      //print("Theme 3: ${appTheme.flutterAppTheme.textTheme.displayLarge}");
      pages.add(ThemeDemoPage(
        theme: appTheme,
        themeNotifier: widget.themeNotifier,
      ));
    }
    setState(() {
      _themePages = pages;
    });
  }

  @override
  void initState() {
    super.initState();
    _setThemePages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a theme"),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.light_mode)),
          Switch(
            value: true,
            onChanged: (val) => {},
            thumbIcon: WidgetStateProperty.all(Icon(Icons.light_mode)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              children: _themePages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SmoothPageIndicator(
              controller: _controller,
              count: _themePages.length,
              effect: ExpandingDotsEffect(
                dotWidth: 12.0,
                dotHeight: 12.0,
                spacing: 16.0,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
