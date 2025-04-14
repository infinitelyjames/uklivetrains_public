import 'package:flutter/material.dart';

class NotificationBlob extends StatelessWidget {
  final String label; // number of notifications

  const NotificationBlob({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.inversePrimary), //Color.fromRGBO(255, 0, 43, 0.7))
        child: Text(
          label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ));
  }
}
