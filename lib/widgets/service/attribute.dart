import 'package:flutter/material.dart';

class AttributeWidget extends StatelessWidget {
  final String label;
  const AttributeWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
      margin: EdgeInsets.all(2),
      child: Text(label),
    );
  }
}
