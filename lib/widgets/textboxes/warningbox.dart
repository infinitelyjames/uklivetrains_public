import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WarningBox extends StatelessWidget {
  const WarningBox(
      {Key? key, required this.text, this.links, this.linkPrefix = "More info"})
      : super(key: key);

  final String text;
  final List<String>? links;
  final String linkPrefix;

  List<Widget> _buildLinksContainer() {
    if (links == null || links! == []) return [];
    List<Widget> widgets = []; // Icon(Icons.open_in_new)
    int count = 1;
    for (String link in links!) {
      widgets.add(InkWell(
        child: Row(
          children: [
            Icon(
              Icons.open_in_new,
              color: Colors.blueAccent,
            ),
            SizedBox(width: 5.0),
            Text(
              links!.length == 1 ? linkPrefix : "$linkPrefix $count",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ],
        ),
        onTap: () => launchUrl(Uri.parse(link)),
      ));
      count++;
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded,
                  color:Color.fromRGBO(231, 135, 25, 0.71)),
              SizedBox(width: 5),
              Expanded(
                  child: Column(
                children: [
                  Text(text, style: TextStyle(fontSize: 15)),
                  ..._buildLinksContainer(),
                ],
              )),
            ],
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Color.fromRGBO(231, 135, 25, 0.71)),
        color: Color.fromRGBO(255, 157, 0, 0.17),
        // boxShadow: [
        //   BoxShadow(
        //     color: Color.fromRGBO(231, 135, 25, 0.17),
        //     blurRadius: 8,
        //     offset: Offset(4, 4),
        //   ),
        // ],
      ),
    );
  }
}
