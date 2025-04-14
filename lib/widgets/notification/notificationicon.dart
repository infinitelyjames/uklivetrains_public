import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const NotificationIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(icon),
        Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color.fromRGBO(
                      255, 0, 43, 0.7)), //Color.fromRGBO(255, 0, 43, 1)
              child: Text(
                "$label",
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ))
      ],
    );
  }
}
