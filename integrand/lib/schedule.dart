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
      _currentTime = DateTime.now();
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
              height: 35.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: ScheduleTimeIndicators(
                bellSchedule: schedule,
                currentTime: _currentTime,
                periodNameToIndicatorMap: periodNameToIndicator,
              ),
            ),
            const SizedBox(
              height: 75,
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
              bellSchedule: bellSchedule,
            ),
            PeriodIndicator(
              indicatorText: indicatorText,
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            MinutesLeftText(
              isPassingPeriod: bellSchedule
                  .isPassingPeriod(TimeOfDay.fromDateTime(currentTime))
                  .$1,
              endTime: endTime,
            ),
          ],
        ),
        const SizedBox(
          height: 45,
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
  const ClockTimerHybrid(
      {super.key, required this.currentDateTime, required this.bellSchedule});

  final DateTime currentDateTime;
  final BellSchedule bellSchedule;

  // TODO: Currently outputs only 12-hour time aka 00:00 AM/PM. Either make this based on device settings or a toggle in the app settings.
  @override
  Widget build(BuildContext context) {
    String output;

    var info =
        bellSchedule.isPassingPeriod(TimeOfDay.fromDateTime(currentDateTime));
    if (info.$1) {
      int minutesLeft = differenceMinutesTimeOfDay(
              info.$3!.startTime, TimeOfDay.fromDateTime(currentDateTime)) -
          1;

      int secondsLeft = 60 - currentDateTime.second;

      if (secondsLeft == 60) {
        secondsLeft = 0;
        minutesLeft++;
      }

      output = "$minutesLeft:$secondsLeft";
    } else {
      output = TimeOfDay.fromDateTime(currentDateTime).format(context);
    }

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
      int hours = minutesLeft ~/ 60;
      minutesLeft = minutesLeft % 60;
      textString =
          "${hours > 0 ? (hours == 1 ? "1 hour and" : "$hours hours") : ""}${hours > 0 && minutesLeft > 0 ? " and " : ""}${minutesLeft > 0 ? (minutesLeft == 1 ? "1 minute" : "$minutesLeft minutes") : ""} left";
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
    double fraction = differenceMinutesTimeOfDay(endTime, currentTime) /
        differenceMinutesTimeOfDay(endTime, startTime);

    fraction *= 0.992;
    fraction += 0.004;

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
            height: heightPixels + 8.0,
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: [
                const TimeLeftBarBackground(),
                Center(
                  widthFactor: fraction,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TimeLeftBarIcon(
                      currentTime: currentTime,
                    ),
                  ),
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
          height: 12,
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
          height: 12,
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
          constraints: const BoxConstraints(minHeight: 5),
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
  final List<Container> textChildren = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, studentVueAPI, child) {
      textChildren.clear();

      // Border element
      Container border = Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: textColor,
                  width: 0.1,
                ),
              ),
            ),
          ),
        ),
      );
      textChildren.add(border);
      int i = 0;
      for (BellPeriod period in widget.bellSchedule.periods) {
        final bool isCurrentPeriod =
            period.isHappening(TimeOfDay.fromDateTime(widget.currentTime));
        final TextStyle textStyle = isCurrentPeriod ? boldBodyStyle : bodyStyle;

        final Course? course =
            studentVueAPI.scheduleData.getCourseByPeriod(period.periodName);

        final String name =
            (course == null) ? period.periodName : course.courseTitle;

        const EdgeInsets textPadding = EdgeInsets.only(
          top: 14,
          bottom: 14,
          left: 25.0,
          right: 25.0,
        );

        Container nextPeriodText = Container(
          color: isCurrentPeriod ? darkGrey : Colors.transparent,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom( // TODO: Change onclick visuals
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: textPadding,
                    child: Text(
                      name,
                      style: textStyle,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: textPadding,
                    child: Text(
                      removeAMPM(period.startTime.format(context)),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: textPadding,
                    child: Text(
                      removeAMPM(period.endTime.format(context)),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        textChildren.add(nextPeriodText);

        double borderWidth = 0.1;

        if (widget.bellSchedule
            .isPassingPeriod(TimeOfDay.fromDateTime(widget.currentTime))
            .$1) {
          if (i < widget.bellSchedule.periods.length - 1) {
            // Check if the passing period is between the current period and the next period
            if (isBetweenTimeOfDayInclusive(
                widget.bellSchedule.periods[i].endTime,
                widget.bellSchedule.periods[i + 1].startTime,
                TimeOfDay.fromDateTime(widget.currentTime))) {
              borderWidth = 1.5;
            }
          }
        }
        textChildren.add(border);
        i++;
      }

      return Column(
        children: textChildren,
      );
    });
  }
}
