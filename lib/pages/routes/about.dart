import 'package:flutter/material.dart';

// Referenced from Settings
class AboutRoute extends StatelessWidget {
  const AboutRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(padding: EdgeInsets.all(10), children: [
        Text("Hi, I'm a cool guy!",
            style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }
}
