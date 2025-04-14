import 'package:flutter/material.dart';

class RouteDenoter extends StatelessWidget {
  const RouteDenoter({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Icon(Icons.alt_route, color: Color.fromRGBO(4, 97, 238, 0.71)),
          SizedBox(width: 5),
          Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        ],
      ),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Color.fromRGBO(4, 97, 238, 0.71)),
        color: Color.fromRGBO(8, 122, 230, 0.169),
      ),
    );
  }
}
