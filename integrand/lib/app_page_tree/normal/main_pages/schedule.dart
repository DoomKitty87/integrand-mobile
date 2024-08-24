import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:integrand/widget_templates.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:integrand/helpers/time_of_day_helpers.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/backend/data_classes.dart';

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
    if (mounted == false) {
      _timer.cancel();
      return;
    }

    // setState(() {
    //   // TODO: Change this to change the timescale of the app
    //   _currentTime = DateTime.fromMillisecondsSinceEpoch(
    //       _currentTime.millisecondsSinceEpoch + 50000);
    //   // print(_currentTime);
    // });
  }

  @override
  void dispose() {
    _timer.cancel;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, value, child) {
      BellSchedule schedule = value.bellSchedule;

      if (schedule.error) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              "No schedule data available.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        );
      }

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
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: ScheduleTimeIndicators(
                bellSchedule: schedule,
                currentTime: _currentTime,
                periodNameToIndicatorMap: periodNameToIndicator,
              ),
            ),
            Expanded(
              child: ScheduleDisplay(
                bellSchedule: schedule,
                currentTime: _currentTime,
                scheduleData: value.scheduleData,
              ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DayOfWeekText(currentTime: currentTime),
        const SizedBox(
          height: 8,
        ),
        // TODO: passing period background goes here in a stack
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimeLarge(
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
              currentTime: TimeOfDay.fromDateTime(currentTime),
              endTime: endTime,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        LayeredProgressIndicator(
          startTime: startTime,
          endTime: endTime,
          currentTime: TimeOfDay.fromDateTime(currentTime),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            removeAMPM(startTime.format(context)),
            style: smallBodyStyle,
          ),
          Text(
            removeAMPM(endTime.format(context)),
            style: smallBodyStyle,
          ),
        ])
      ],
    );
  }
}

class DayOfWeekText extends StatelessWidget {
  const DayOfWeekText({super.key, required this.currentTime});

  final DateTime currentTime;

  @override
  Widget build(BuildContext context) {
    String timeOfDayLabel;
    String dayLabel;

    timeOfDayLabel = currentTime.hour < 12 ? " morning" : " afternoon";
    dayLabel = weekdayToName(currentTime.weekday) + timeOfDayLabel;

    return Text(
      textAlign: TextAlign.left,
      dayLabel,
      style: bodyStyle,
    );
  }
}

class TimeLarge extends StatelessWidget {
  const TimeLarge(
      {super.key, required this.currentDateTime, required this.bellSchedule});

  final DateTime currentDateTime;
  final BellSchedule bellSchedule;

  @override
  Widget build(BuildContext context) {
    String output;

    var info =
        bellSchedule.isPassingPeriod(TimeOfDay.fromDateTime(currentDateTime));
    if (info.$1) {
      // if passing period
      int minutesLeft = differenceMinutesTimeOfDay(
              info.$3!.startTime, TimeOfDay.fromDateTime(currentDateTime)) -
          1;
      int secondsLeft = 60 - currentDateTime.second;

      if (secondsLeft == 60) {
        secondsLeft = 0;
        minutesLeft++;
      }
      output =
          "$minutesLeft:${secondsLeft > 9 ? secondsLeft : '0$secondsLeft'}";
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
      {super.key,
      required this.isPassingPeriod,
      required this.currentTime,
      required this.endTime});

  final bool isPassingPeriod;
  final TimeOfDay currentTime;
  final TimeOfDay endTime;

  @override
  Widget build(BuildContext context) {
    String textString = "";

    if (isPassingPeriod) {
      textString = "minutes left";
    } else {
      int minutesLeft = differenceMinutesTimeOfDay(endTime, currentTime);

      // Hours
      int hours = minutesLeft ~/ 60;
      minutesLeft = minutesLeft % 60;

      if (hours > 0) {
        if (hours == 1) {
          textString += "1 hour ";
        } else {
          textString += "$hours hours ";
        }
      }
      if (minutesLeft >= 0) {
        if (hours > 0) textString += "and ";
        if (minutesLeft == 1) {
          textString += "1 minute ";
        } else {
          textString += "$minutesLeft minutes ";
        }
      }
      textString += "left";
    }

    return Text(
      textString,
      textAlign: TextAlign.left,
      style: bodyStyle,
    );
  }
}

class LayeredProgressIndicator extends StatelessWidget {
  const LayeredProgressIndicator(
      {super.key,
      required this.startTime,
      required this.endTime,
      required this.currentTime});

  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TimeOfDay currentTime;

  @override
  Widget build(BuildContext context) {
    final int total = differenceMinutesTimeOfDay(endTime, startTime);
    final int current = differenceMinutesTimeOfDay(currentTime, startTime);

    final double progress = current / total;

    final int flex1 = (progress * 100).toInt();
    final int flex2 = 100 - flex1;

    return Row(
      children: [
        Expanded(
          flex: flex1,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: textGradient,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: textColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Expanded(
          flex: flex2,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: lighterGrey,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}

// Schedule Display =================================================================================================================================================

String removeAMPM(String time) {
  if (time.toLowerCase().contains("AM") || time.toLowerCase().contains("PM")) {
    return time.substring(0, time.length - 3);
  } else {
    return time;
  }
}

class ScheduleDisplay extends StatelessWidget {
  const ScheduleDisplay({super.key, required this.bellSchedule, required this.currentTime, required this.scheduleData});

  final BellSchedule bellSchedule;
  final ScheduleData scheduleData;
  final DateTime currentTime;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: ListView.builder(
        itemCount: bellSchedule.periods.length,
        itemBuilder: (context, index) {
          BellPeriod period = bellSchedule.periods[index];
          return ScheduleExpandableListItem(
            period: period,
            currentTime: currentTime,
            scheduleData: scheduleData,
          );
        },
      ),
    );
  }
}

class ScheduleExpandableListItem extends StatelessWidget {
  const ScheduleExpandableListItem({super.key, required this.period, required this.currentTime, required this.scheduleData});

  final BellPeriod period;
  final DateTime currentTime;
  final ScheduleData scheduleData;

  @override
  Widget build(BuildContext context) {
    Course? course = scheduleData.getCourseByPeriod(period.periodName);
    String name = course == null ? period.periodName : course.courseTitle;

    return ExpandableListItem(
      unexpandedHeight: 50,
      expandedHeight: 100,
      highlighted: true,
      expandedChild: Container(
        height: 50,
        child: Placeholder(),
      ),
      child: Container(
        height: 50,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(name),
            ),
            Expanded(
              flex: 1,
              child: Text(removeAMPM(period.startTime.format(context))),
            ),
            Expanded(
              flex: 1,
              child: Text(removeAMPM(period.endTime.format(context))),
            ),
          ],
        ),
      ),
    );
  }
}
