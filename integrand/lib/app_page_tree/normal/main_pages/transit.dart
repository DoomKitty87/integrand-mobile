import 'dart:math';

import 'package:flutter/material.dart';
import 'package:integrand/backend/transit_api.dart';
import 'package:integrand/consts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class Transit extends StatefulWidget {
  const Transit({super.key});

  @override
  State<Transit> createState() => _TransitState();
}

class _TransitState extends State<Transit> {
  bool enteringNewStop = false;
  String currentSearch = "";

  @override
  Widget build(BuildContext context) {
    List<Stop> searchedStops = Provider.of<TransitAPI>(context, listen: false)
        .staticStopData
        .where((element) =>
            (element.name.toLowerCase().contains(currentSearch.toLowerCase()) ||
                element.id.toString().contains(currentSearch)) &&
            !Provider.of<TransitAPI>(context, listen: false)
                .savedStops
                .map((e) => e.id)
                .contains(element.id))
        .take(10)
        .toList();

    return Consumer<TransitAPI>(
      builder: (context, transitAPI, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: ListView(children: [
            if (enteringNewStop)
              Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Stop Name or ID",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: textColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: textColor),
                              ),
                              labelStyle: bodyStyle,
                            ),
                            cursorColor: textColor.withOpacity(0.8),
                            onChanged: (String value) {
                              setState(() {
                                currentSearch = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                enteringNewStop = false;
                                currentSearch = "";
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (Stop stop in searchedStops)
                    GestureDetector(
                        onTap: () {
                          transitAPI.addSavedStop(StopLive(
                              stop.id,
                              stop.name,
                              stop.latitude,
                              stop.longitude,
                              stop.direction,
                              stop.routes));
                          setState(() {
                            enteringNewStop = false;
                            currentSearch = "";
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(stop.name, style: bodyStyle)),
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: darkGrey,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(stop.direction[0],
                                      style: boldBodyStyle),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(stop.id.toString(), style: bodyStyle),
                            ],
                          ),
                        )),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Saved Stops", style: mediumTitleStyle),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: textColor,
                  onPressed: () {
                    setState(
                      () => enteringNewStop = true,
                    );
                  },
                ),
              ],
            ),
            for (StopLive stop in transitAPI.savedStops)
              SavedStopCard(
                stop: stop,
              ),
            const SizedBox(height: 20),
            const Text("Nearby Stops", style: mediumTitleStyle),
            const SizedBox(height: 10),
            for (StopLive stop in transitAPI.nearbyStops)
              NearbyStopCard(
                stop: stop,
              ),
          ]),
        );
      },
    );
  }
}

String truncate(String text, int length) {
  if (text.length > length) {
    return "${text.substring(0, length)}...";
  }
  return text;
}

String getFutureArrivals(List<dynamic> arrivals) {
  String futureArrivals = "";

  for (int i = 1; i < arrivals.length; i++) {
    futureArrivals +=
        " ${formatDuration(max(int.parse(((arrivals[i]["estimated"] ?? arrivals[i]["scheduled"]) - DateTime.now().millisecondsSinceEpoch).toString()), 0))}";

    if (i < arrivals.length - 1) {
      futureArrivals += ",";
    }
  }

  return futureArrivals;
}

class SavedStopCard extends StatefulWidget {
  const SavedStopCard({super.key, required this.stop});

  final StopLive stop;

  @override
  State<SavedStopCard> createState() => _SavedStopCardState();
}

class _SavedStopCardState extends State<SavedStopCard> {
  bool expanded = false;

  List<int> ignoredRoutes = [];

  @override
  Widget build(BuildContext context) {
    if (widget.stop.arrivals.isEmpty) {
      return Container();
    }

    List<dynamic> arrivals = widget.stop.arrivals
        .where((element) => !ignoredRoutes.contains(element["route"]))
        .toList();

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: lighterGrey),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(truncate(widget.stop.name, 16),
                              style: boldBodyStyle),
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: darkGrey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                                child: Text(widget.stop.direction[0],
                                    style: boldBodyStyle)),
                          ),
                        ],
                      ),
                      if (arrivals.isNotEmpty)
                        Row(
                          children: [
                            SizedBox(
                              height: 25,
                              child: Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    color: HexColor(arrivals[0]["routeColor"]),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      arrivals[0]["route"].toString(),
                                      style: boldBodyStyle,
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                                truncate(
                                    arrivals[0]["shortSign"]
                                        .toString()
                                        .replaceFirst(
                                            "${arrivals[0]["route"]}", ""),
                                    15),
                                style: bodyStyle),
                          ],
                        )
                    ],
                  ),
                ),
                if (arrivals.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: Text(
                        formatDuration(max(
                                int.parse(((arrivals[0]["estimated"] ??
                                            arrivals[0]["scheduled"]) -
                                        DateTime.now().millisecondsSinceEpoch)
                                    .toString()),
                                0))
                            .toString(),
                        style: mediumTitleStyle,
                        textAlign: TextAlign.right),
                  ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                            expanded
                                ? Icons.arrow_drop_up_sharp
                                : Icons.arrow_drop_down_sharp,
                            color: textColor),
                        color: textColor,
                        onPressed: () {
                          // Open dropdown menu
                          setState(() {
                            expanded = !expanded;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (expanded)
            Column(children: [
              arrivals.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 10, top: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BusRouteIndicator(
                                  arrival: arrivals[0],
                                ),
                                ArrivalTimeIndicator(
                                  arrival: arrivals[0],
                                ),
                              ],
                            ),
                            widget.stop.arrivals.length > 1
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: RichText(
                                        text: TextSpan(
                                      children: <TextSpan>[
                                        const TextSpan(
                                          text: "More in:",
                                          style: boldBodyStyle,
                                        ),
                                        TextSpan(
                                          text: getFutureArrivals(arrivals),
                                          style: bodyStyle,
                                        ),
                                      ],
                                    )),
                                  )
                                : const Text("No more arrivals soon",
                                    style: boldBodyStyle),
                          ]),
                    )
                  : const Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, bottom: 10, top: 10),
                      child: Text("No arrivals found", style: boldBodyStyle),
                    ),
              Container(
                height: 1,
                color: lighterGrey,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Routes:", style: bodyStyle),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: 30,
                      width: 210,
                      child:
                          ListView(scrollDirection: Axis.horizontal, children: [
                        for (var route in widget.stop.routes)
                          GestureDetector(
                            onTap: () {
                              // Toggle route visibility
                              setState(() {
                                if (ignoredRoutes.contains(route)) {
                                  ignoredRoutes.remove(route);
                                } else {
                                  ignoredRoutes.add(route);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: ignoredRoutes.contains(route)
                                    ? lightGrey
                                    : darkGrey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  route.toString(),
                                  style: boldBodyStyle,
                                ),
                              ),
                            ),
                          ),
                      ]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: textColor),
                      color: textColor,
                      onPressed: () {
                        // Remove stop from saved stops
                        Provider.of<TransitAPI>(context, listen: false)
                            .removeSavedStop(widget.stop);
                      },
                    ),
                  ],
                ),
              )
            ])
        ],
      ),
    );
  }
}

class BusRouteIndicator extends StatelessWidget {
  const BusRouteIndicator({super.key, required this.arrival});

  final Map<String, dynamic> arrival;

  @override
  Widget build(BuildContext context) {
    if (arrival["blockPosition"] == null) {
      return const SizedBox(
        width: 160,
      );
    }

    int prevStopId = arrival["blockPosition"]!["lastLocID"] ?? -1;
    int nextStopId = arrival["blockPosition"]!["nextLocID"] ?? -1;

    Stop? prevStop;
    Stop? nextStop;

    String prevStopName = "";
    String nextStopName = "";

    if (prevStopId != -1) {
      prevStop = Provider.of<TransitAPI>(context, listen: false)
          .staticStopData
          .firstWhere((element) => element.id == prevStopId);
      prevStopName = prevStop.name;
    }

    if (nextStopId != -1) {
      nextStop = Provider.of<TransitAPI>(context, listen: false)
          .staticStopData
          .firstWhere((element) => element.id == nextStopId);
      nextStopName = nextStop.name;
    }

    double fractionComplete = 0.0;

    if (prevStop != null && nextStop != null && prevStop != nextStop) {
      fractionComplete = Geolocator.distanceBetween(
              prevStop.latitude,
              prevStop.longitude,
              arrival["blockPosition"]["lat"],
              arrival["blockPosition"]["lng"]) /
          Geolocator.distanceBetween(prevStop.latitude, prevStop.longitude,
              nextStop.latitude, nextStop.longitude);
    }

    return SizedBox(
      width: 160,
      child: Column(
        children: [
          Row(children: [
            Expanded(
              flex: (100 * fractionComplete).toInt(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: textGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
                height: 5,
              ),
            ),
            Expanded(
              flex: (100 * (1 - fractionComplete)).toInt(),
              child: Container(
                decoration: const BoxDecoration(
                  color: darkGrey,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                height: 5,
              ),
            ),
          ]),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 80,
                  child: Text(
                    prevStopName,
                    style: smallBodyStyle,
                  )),
              SizedBox(
                  width: 80,
                  child: Text(
                    nextStopName,
                    style: smallBodyStyle,
                    textAlign: TextAlign.right,
                  )),
            ],
          )
        ],
      ),
    );
  }
}

class ArrivalTimeIndicator extends StatelessWidget {
  const ArrivalTimeIndicator({super.key, required this.arrival});

  final Map<String, dynamic> arrival;

  @override
  Widget build(BuildContext context) {
    String arrivalTime = TimeOfDay.fromDateTime(
            DateTime.fromMillisecondsSinceEpoch(
                arrival["estimated"] ?? arrival["scheduled"]))
        .format(context);

    String arrivalStatus = "On time";

    if (arrival["status"] == "estimated" &&
        arrival["estimated"] != arrival["scheduled"]) {
      int difference = arrival["estimated"] - arrival["scheduled"];

      if (difference >= 60000) {
        arrivalStatus =
            "${difference ~/ 60000} minute${difference ~/ 60000 > 1 ? "s" : ""} late";
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Arrival $arrivalTime",
            style: bodyStyle,
          ),
          Text(
            arrivalStatus,
            style: bodyStyle.copyWith(
              color: arrivalStatus == "On time" ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

String formatDuration(int milliseconds) {
  int minutes = (milliseconds / 60000).floor();
  int hours = (minutes / 60).floor();

  if (hours > 99) {
    return "99h";
  }

  if (hours > 0) {
    return "${hours}hr ${minutes % 60}min";
  } else {
    return "$minutes min";
  }
}

class NearbyStopCard extends StatelessWidget {
  const NearbyStopCard({super.key, required this.stop});

  final StopLive stop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(truncate(stop.name, 16), style: boldBodyStyle),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: darkGrey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                          child: Text(stop.direction[0], style: boldBodyStyle)),
                    ),
                  ],
                ),
                if (stop.arrivals.isNotEmpty)
                  Row(
                    children: [
                      SizedBox(
                        height: 25,
                        child: Container(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              color: HexColor(stop.arrivals[0]["routeColor"]),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                stop.arrivals[0]["route"].toString(),
                                style: boldBodyStyle,
                              ),
                            )),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                          truncate(
                              stop.arrivals[0]["shortSign"]
                                  .toString()
                                  .replaceFirst(
                                      "${stop.arrivals[0]["route"]}", ""),
                              15),
                          style: bodyStyle),
                    ],
                  )
              ],
            ),
          ),
          if (stop.arrivals.isNotEmpty)
            Expanded(
              flex: 2,
              child: Text(
                  formatDuration(max(
                          int.parse(((stop.arrivals[0]["estimated"] ??
                                      stop.arrivals[0]["scheduled"]) -
                                  DateTime.now().millisecondsSinceEpoch)
                              .toString()),
                          0))
                      .toString(),
                  style: mediumTitleStyle,
                  textAlign: TextAlign.right),
            ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: textColor),
                  color: textColor,
                  onPressed: () {
                    // Add stop to saved stops
                    Provider.of<TransitAPI>(context, listen: false)
                        .addSavedStop(stop);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
