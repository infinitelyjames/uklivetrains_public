// Widget to denote that something is loading. IS NOT just a simple loading circle.
import 'package:flutter/material.dart';

class LoadingBox extends StatelessWidget {
  const LoadingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Color.fromRGBO(4, 97, 238, 0.71)),
        color: Color.fromRGBO(8, 122, 230, 0.169),
      ),
      child: const Row(
        children: [
          SizedBox(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(4, 97, 238, 0.71),
              strokeWidth: 2.5,
            ),
            height: 15,
            width: 15,
          ), // Icon(Icons.downloading, color: Color.fromRGBO(4, 97, 238, 0.71))
          SizedBox(width: 8),
          Expanded(child: Text("Loading...", style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
