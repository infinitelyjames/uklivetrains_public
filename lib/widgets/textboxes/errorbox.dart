import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Color.fromRGBO(238, 4, 4, 0.71)),
          SizedBox(width: 5),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15))),
        ],
      ),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Color.fromRGBO(238, 39, 4, 0.71)),
        color: Color.fromRGBO(230, 41, 8, 0.169),
      ),
    );
  }
}
