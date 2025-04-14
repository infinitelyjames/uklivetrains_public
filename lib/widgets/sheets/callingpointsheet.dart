import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/api.dart';
import 'package:uklivetrains/pages/routes/trainlist.dart';
import 'package:uklivetrains/structs/callingpoint.dart';
import 'package:url_launcher/url_launcher.dart';

class CallingPointSheet extends StatelessWidget {
  final CallingPoint callingPoint;
  final bool dividesHere;
  const CallingPointSheet(
      {super.key, required this.callingPoint, required this.dividesHere});

  @Deprecated("Migrate to summary widgets and away from long paragraphs")
  String _getDepartureText() {
    if (callingPoint.estimatedTime.toLowerCase() == "cancelled") {
      return "This train has been cancelled at this station. When finding alternative trains, make sure your ticket is valid on these services. In the event of publicised service disruption, the service disruption webpage will contains details of what trains your ticket is valid on.";
    } else if (callingPoint.estimatedTime.toLowerCase() == "delayed") {
      return "This train is currently delayed at this station, and the estimated departure time is unknown.";
    } else {
      String text =
          "Scheduled at ${callingPoint.scheduledTime} and ${callingPoint.departedYet ? 'departed at' : 'estimated to depart at'} ${callingPoint.estimatedTime}.";
      if (callingPoint.platform != null)
        text += " Departs from platform ${callingPoint.platform}.";
      return text;
    }
  }

  Widget _returnDetailsContainer(BuildContext context, List<Widget> widgets) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.2), width: 1),
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).brightness == Brightness.light ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [...widgets]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContainer(BuildContext context) {
    List<Widget> widgets = [
      if (callingPoint.delayCancelReason != null) 
      ListTile(
        title: Text(
          callingPoint.delayCancelReason!,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.00, color: Colors.red),
        ),
        // subtitle: callingPoint.platform != null
        //     ? null
        //     : Text(
        //         callingPoint.delayCancelReason!,
        //         style: Theme.of(context)
        //             .textTheme
        //             .bodySmall!
        //             .copyWith(height: 1.00),
        //       ),// TODO: platform query functionality
      ),
      if (callingPoint.delayCancelReason != null) 
      const Divider(height: 1),
      ListTile(
        title: Text(
          "Scheduled",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: Text(
          callingPoint.scheduledTime,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      const Divider(height: 1),
      ListTile(
        title: Text(
          callingPoint.departedYet ? "Departed at" : "Departs",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: Text(
          callingPoint.estimatedTime,
          style: callingPoint.estimatedTime == callingPoint.scheduledTime
              ? Theme.of(context).textTheme.bodyLarge
              : Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.red),
        ),
      ),
      const Divider(height: 1),
      ListTile(
        title: Text(
          "Platform",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.00),
        ),
        subtitle: callingPoint.platform != null
            ? null
            : Text(
                "Tap to find predicted platform",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(height: 1.00),
              ),
        trailing: Text(
          callingPoint.platform ?? "--",
          style: Theme.of(context).textTheme.bodyLarge,
        ), // TODO: platform query functionality
      ),
      if (callingPoint.coaches != null) const Divider(height: 1),
      if (callingPoint.coaches != null)
        ListTile(
          title: Text(
            "Coaches",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          trailing: Text(
            callingPoint.coaches!.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      const Divider(height: 1),
      ListTile(
        title: Text(
          "Live Departure Board",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LiveTrainsRoutePage(
                        startStationCRS: callingPoint.crs,
                        destinationStationCRS: null,
                      ))),
        ),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LiveTrainsRoutePage(
                      startStationCRS: callingPoint.crs,
                      destinationStationCRS: null,
                    ))),
      ),
      const Divider(height: 1),
      ListTile(
        title: Text(
          "Station Information",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.launch),
          onPressed: () =>
              launchUrl(Uri.parse(callingPoint.getStationDetailsURL())),
        ),
        onTap: () => launchUrl(Uri.parse(callingPoint.getStationDetailsURL())),
      ),
    ];
    return _returnDetailsContainer(context, widgets);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return ListView(
            padding: const EdgeInsets.all(15),
            controller: scrollController,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // TODO prevent horizontal overflow (test case birmingham international - BHI)
                      Text(
                        callingPoint.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "(${callingPoint.crs})",
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  // ToDo - make below better for cancellations and delays
                  Column(
                    children: [
                      _buildDetailsContainer(context),
                      // Text(_getDepartureText()),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     FilledButton.tonal(
                      //       onPressed: () => Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => LiveTrainsRoutePage(
                      //                     startStationCRS: callingPoint.crs,
                      //                     destinationStationCRS: null,
                      //                   ))),
                      //       child: const Text("Live departure board"),
                      //     ),
                      //     FilledButton.tonal(
                      //       // TODO - make this link directly to station
                      //       onPressed: () => launchUrl(
                      //           Uri.parse(callingPoint.getStationDetailsURL())),
                      //       child: const Text("Station information"),
                      //     ),
                      //   ],
                      // ),
                    ],
                  )
                ],
              )
            ]);
      },
    );
  }
}
