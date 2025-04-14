import 'package:flutter/material.dart';

class TrainSummaryPaneAttribute extends StatelessWidget {
  final Widget? leading;
  final String? titleText;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailing;

  const TrainSummaryPaneAttribute({
    super.key,
    this.leading,
    this.titleText,
    this.subtitle,
    this.trailing,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: titleText != null
          ? Text(titleText!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.00))
          : null,
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(height: 1.00))
          : null,
      trailing: trailing ??
          (trailingText != null
              ? Text(trailingText!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(height: 1.00))
              : null),
      contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      dense: true,
    );
  }
}
