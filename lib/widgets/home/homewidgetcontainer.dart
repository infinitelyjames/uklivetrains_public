import 'package:flutter/material.dart';

const double OUTER_BORDER_RADIUS = 15;

class HomeWidgetContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget containedWidget;

  const HomeWidgetContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.containedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(OUTER_BORDER_RADIUS),
        color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(255, 255, 255, 0.3) : const Color.fromRGBO(0, 0, 0, 0.3),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OUTER_BORDER_RADIUS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.3), // Color.fromRGBO(0, 0, 0, 0.15)
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: containedWidget,
            ),
          ],
        ),
      ),
    );
  }
}
