import 'package:flutter/material.dart';

typedef Callback = void Function();

class SettingsLinkWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Callback? onTapCallback;

  const SettingsLinkWidget(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Icon(Icons.keyboard_arrow_right_rounded),
      onTap: onTapCallback,
    );
  }
}
