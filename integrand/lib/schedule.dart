import 'package:flutter/material.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'helpers/time_of_day_helpers.dart';
import 'consts.dart';
import 'backend/data_classes.dart';

// Main Widget
// ============================================================================================

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  late Timer _timer;
  DateTime _currentTime = testDateTime;

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) => _update());
  }

  void _update() {
    setState(() {
      _currentTime = testDateTime;
    });
  }

  @override
  void dispose() {
    _timer.cancel;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, value, child) {
      // TODO: Uncomment this when school starts lmao
      // BellSchedule schedule = value.bellSchedule;

      BellSchedule schedule = testASchedule;
      if (schedule.isOutsideSchoolHours(TimeOfDay.fromDateTime(_currentTime))) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              "No school today.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        );
      } else {
        return Column(
          children: [
            const SizedBox(
              height: 55.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ScheduleTimeIndicators(
                bellSchedule: schedule,
                currentTime: _currentTime,
                periodNameToIndicatorMap: periodNameToIndicator,
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            ScheduleDisplay(
              bellSchedule: schedule,
              currentTime: _currentTime,
            ),
          ],
        );
      }
    });
  }
}

class ScheduleTimeIndicators extends StatelessWidget {
  const ScheduleTimeIndicators(
      {super.key,
      required this.bellSchedule,
      required this.periodNameToIndicatorMap,
      required this.currentTime});

  final BellSchedule bellSchedule;
  final Map periodNameToIndicatorMap;
  final DateTime currentTime;

  @override
  Widget build(BuildContext context) {
    TimeOfDay startTime;
    TimeOfDay endTime;
    String indicatorText;

    var data =
        bellSchedule.isPassingPeriod(TimeOfDay.fromDateTime(currentTime));

    if (data.$1 == true) {
      startTime = data.$2!.endTime;
      endTime = data.$3!.startTime;
      indicatorText = periodNameToIndicatorMap[""]; // Passing period indicator
    } else {
      BellPeriod period =
          bellSchedule.getCurrentPeriod(TimeOfDay.fromDateTime(currentTime))!;
      startTime = period.startTime;
      endTime = period.endTime;
      indicatorText = periodNameToIndicatorMap[period.periodName];
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClockTimerHybrid(
              currentDateTime: currentTime,
            ),
            PeriodIndicator(
              indicatorText: indicatorText,
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            MinutesLeftText(
              isPassingPeriod: bellSchedule
                  .isPassingPeriod(TimeOfDay.fromDateTime(currentTime))
                  .$1,
              endTime: periodEnd,
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        TimeLeftBar(
          heightPixels: 20,
          startTime: startTime,
          endTime: endTime,
          currentTime: TimeOfDay.fromDateTime(currentTime),
        ),
      ],
    );
  }
}

class ClockTimerHybrid extends StatelessWidget {
  const ClockTimerHybrid({super.key, required this.currentDateTime});

  final DateTime currentDateTime;

  // TODO: Currently outputs only 12-hour time aka 00:00 AM/PM. Either make this based on device settings or a toggle in the app settings.
  @override
  Widget build(BuildContext context) {
    String output;
    output = TimeOfDay.fromDateTime(currentDateTime).format(context);

    return Text(
      output,
      style: titleStyle,
    );
  }
}

class PeriodIndicator extends StatelessWidget {
  const PeriodIndicator({super.key, required this.indicatorText});

  final String indicatorText;

  @override
  Widget build(BuildContext context) {
    return Text(
      indicatorText,
      textAlign: TextAlign.left,
      style: subtitleStyle,
    );
  }
}

class MinutesLeftText extends StatelessWidget {
  const MinutesLeftText(
      {super.key, required this.isPassingPeriod, required this.endTime});

  final bool isPassingPeriod;
  final TimeOfDay endTime;

  @override
  Widget build(BuildContext context) {
    String textString;

    if (isPassingPeriod) {
      textString = "minutes left";
    } else {
      int minutesLeft = differenceMinutesTimeOfDay(endTime, TimeOfDay.now());

      // Hours
      int hours = minutesLeft % 60;
      minutesLeft = minutesLeft ~/ 60;

      textString =
          "${hours > 0 ? (hours == 1 ? "1 hour and" : "$hours hours and") : ""} ${minutesLeft > 0 ? (minutesLeft == 1 ? "1 minute" : "$minutesLeft minutes") : ""} left";
    }

    return Text(
      textString,
      textAlign: TextAlign.left,
      style: bodyStyle,
    );
  }
}

// TODO: Finish time left bar

class TimeLeftBar extends StatelessWidget {
  const TimeLeftBar(
      {super.key,
      required this.heightPixels,
      required this.startTime,
      required this.currentTime,
      required this.endTime});

  final TimeOfDay startTime;
  final TimeOfDay currentTime;
  final TimeOfDay endTime;
  final double heightPixels;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 5.0,
            right: 5.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TimeText(
                time: startTime,
                textAlign: TextAlign.left,
              ),
              TimeText(
                time: endTime,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        SizedBox(
            height: heightPixels,
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: [
                TimeLeftBarBackground(),
                TimeLeftBarIcon(
                  currentTime: currentTime,
                ),
              ],
            )),
      ],
    );
  }
}

class TimeLeftBarBackground extends StatelessWidget {
  const TimeLeftBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 1,
          color: textColor,
        ),
        Expanded(
          child: Container(
            height: 1,
            color: textColor,
          ),
        ),
        Container(
          width: 1,
          color: textColor,
        ),
      ],
    );
  }
}

// TODO: Finish this icon, make it a resonable size with widget inspector and position it properly
class TimeLeftBarIcon extends StatelessWidget {
  const TimeLeftBarIcon({super.key, required this.currentTime});

  final TimeOfDay currentTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: textColor,
              width: 1,
            ),
          ),
          constraints: BoxConstraints(minHeight: 5),
        ),
        TimeText(
          time: currentTime,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class TimeText extends StatelessWidget {
  const TimeText({super.key, required this.time, required this.textAlign});

  final TimeOfDay time;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      removeAMPM(time.format(context)),
      textAlign: textAlign,
      style: smallBodyStyle,
    );
  }
}

// Schedule Display =================================================================================================================================================

String removeAMPM(String time) {
  return time.substring(0, time.length - 3);
}

class ScheduleDisplay extends StatefulWidget {
  const ScheduleDisplay(
      {super.key, required this.bellSchedule, required this.currentTime});

  final BellSchedule bellSchedule;
  final DateTime currentTime;

  @override
  State<ScheduleDisplay> createState() => _ScheduleDisplayState();
}

class _ScheduleDisplayState extends State<ScheduleDisplay> {
  final List<TableRow> textChildren = [];
  final List<TableRow> backgroundChildren = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, studentVueAPI, child) {
      textChildren.clear();
      backgroundChildren.clear();

      for (BellPeriod period in widget.bellSchedule.periods) {
        final bool isCurrentPeriod =
            period.isHappening(TimeOfDay.fromDateTime(widget.currentTime));
        final TextStyle textStyle = isCurrentPeriod ? boldBodyStyle : bodyStyle;

        final Course? course =
            studentVueAPI.scheduleData.getCourseByPeriod(period.periodName);

        final String name =
            (course == null) ? period.periodName : course.courseTitle;

        const Decoration textDecoration = BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: textColor,
              width: 0.0,
            ),
          ),
        );

        final Decoration backgroundDecoration = BoxDecoration(
          color: isCurrentPeriod ? darkGrey : Colors.transparent,
        );

        const EdgeInsets textPadding = EdgeInsets.only(
          top: 14.5,
          bottom: 14.5,
          left: 20.0,
          right: 20.0,
        );

        TableRow nextPeriodText = TableRow(
          decoration: textDecoration,
          children: [
            Padding(
              padding: textPadding,
              child: Text(
                name,
                style: textStyle,
              ),
            ),
            Padding(
              padding: textPadding,
              child: Text(
                removeAMPM(period.startTime.format(context)),
                style: textStyle,
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: textPadding,
              child: Text(
                removeAMPM(period.endTime.format(context)),
                style: textStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
        textChildren.add(nextPeriodText);

        TableRow nextPeriodBackground = TableRow(
          children: [
            Container(
              decoration: backgroundDecoration,
              child: const SizedBox(
                height: 50,
              ),
            )
          ],
        );
        backgroundChildren.add(nextPeriodBackground);
      }

      return Stack(children: [
        // Background
        Table(
          children: backgroundChildren,
        ),
        // Text
        Table(
          children: textChildren,
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
        ),
      ]);
    });
  }
}
