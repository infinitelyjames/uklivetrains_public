import 'package:flutter/material.dart';
import 'package:uklivetrains/pages/routes/trainlist.dart';
import 'package:uklivetrains/structs/stationboardquery.dart';

typedef Callback = void Function();

class StationBoardQuerySummaryWidget extends StatelessWidget {
  final StationBoardQuery stationBoardQuery;
  final Callback onDeleteCallback;

  const StationBoardQuerySummaryWidget({
    super.key,
    required this.stationBoardQuery,
    required this.onDeleteCallback,
  });

  void _onclick(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            // TODO: pass filters
            builder: (context) => LiveTrainsRoutePage(
                  startStationCRS: stationBoardQuery.startStation.crs,
                  destinationStationCRS:
                      stationBoardQuery.destinationStation?.crs,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _onclick(context),
      title: Text(stationBoardQuery.startStation.name),
      subtitle: stationBoardQuery.destinationStation != null
          ? Text("to ${stationBoardQuery.destinationStation!.name}")
          : null,
      trailing: IconButton(
        onPressed: () => onDeleteCallback(),
        icon: Icon(Icons.delete_outline_rounded),
        color: Color.fromRGBO(253, 45, 18, 0.621),
      ),
      contentPadding: EdgeInsets.only(left: 13, right: 4),
    );
  }
}

/* Old 
return GestureDetector(
      onTap: () => _onclick(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 1, 10, 1),
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.5), width: 2),
          borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(28),
              topRight: Radius.circular(28),
              bottomLeft: Radius.circular(28),
              topLeft: Radius.circular(6)),
          color: Color.fromRGBO(226, 226, 226, 0.75),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${stationBoardQuery.startStation.name}${stationBoardQuery.destinationStation == null ? '' : ' to ${stationBoardQuery.destinationStation!.name}'}",
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w400, height: 1.05),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => onDeleteCallback(),
              icon: Icon(Icons.delete_outline_rounded),
              color: Color.fromRGBO(253, 45, 18, 0.621),
            ),
            // IconButton.filledTonal(
            //     onPressed: () => _onclick(context),
            //     icon: Icon(Icons.chevron_right_rounded)),
          ],
        ),
      ),
    );

*/