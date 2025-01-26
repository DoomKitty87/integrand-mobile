import 'package:flutter/material.dart';
import 'package:integrand/widget_templates.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:integrand/helpers/time_of_day_helpers.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/main.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:integrand/backend/studentvue_api/studentvue_api.dart';

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
    _timer = Timer.periodic(
        const Duration(milliseconds: 1000), (timer) => _update());
  }

  void _update() {
    if (mounted == false) {
      _timer.cancel();
      return;
    }

    setState(() {
      // TODO: This should be the current real time, right? (For production)
      // TODO: Change this to change the timescale of the app
      _currentTime = DateTime.fromMillisecondsSinceEpoch(
          _currentTime.millisecondsSinceEpoch + 1000);
      // print(_currentTime);
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
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: ScheduleTimeIndicators(
                  bellSchedule: schedule,
                  currentTime: _currentTime,
                  periodNameToIndicatorMap: periodNameToIndicator,
                ),
              ),
            ),
            Expanded(
              flex: 9,
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
  const ScheduleTimeIndicators({
    super.key,
    required this.bellSchedule,
    required this.periodNameToIndicatorMap,
    required this.currentTime,
  });

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
          startTime: TimeOfDayPrecise.fromTimeOfDay(startTime),
          endTime: TimeOfDayPrecise.fromTimeOfDay(endTime),
          currentTime: TimeOfDayPrecise.fromDateTime(currentTime),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            removeAMPM(startTime.format(context)),
            style: labelStyle,
          ),
          Text(
            removeAMPM(endTime.format(context)),
            style: labelStyle,
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
  const LayeredProgressIndicator({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.currentTime,
  });

  final TimeOfDayPrecise startTime;
  final TimeOfDayPrecise endTime;
  final TimeOfDayPrecise currentTime;

  @override
  Widget build(BuildContext context) {
    final int total = endTime.toMilliseconds() - startTime.toMilliseconds();
    final int current =
        total - (endTime.toMilliseconds() - currentTime.toMilliseconds());

    final double progress = current / total;

    final int flex1 = (progress * 1000).toInt();
    final int flex2 = 1000 - flex1;

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
            color: textWhite,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Expanded(
          flex: flex2,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: background3,
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
  if (time.toLowerCase().contains("am") || time.toLowerCase().contains("pm")) {
    return time.substring(0, time.length - 3);
  } else {
    return time;
  }
}

String cleanClassName(String className) {
  // Remove number in parentheses at beginning of class name
  className = className.replaceFirst(RegExp(r"^\(\d+\)"), "");
  // Remove em dash with spaces around it
  className = className.replaceAll(" - ", " ");

  return className;
}

class ScheduleDisplayListLegend extends StatelessWidget {
  const ScheduleDisplayListLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 9,
          child: Text(
            "Class",
            style: bodyStyleBold,
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            "Start",
            textAlign: TextAlign.center,
            style: bodyStyleBold,
          ),
        ),
        Expanded(flex: 1, child: SizedBox()),
        Expanded(
          flex: 2,
          child: Text(
            "End",
            textAlign: TextAlign.center,
            style: bodyStyleBold,
          ),
        ),
      ],
    );
  }
}

class ScheduleDisplay extends StatelessWidget {
  const ScheduleDisplay({
    super.key,
    required this.bellSchedule,
    required this.currentTime,
    required this.scheduleData,
  });

  final BellSchedule bellSchedule;
  final ScheduleData scheduleData;
  final DateTime currentTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: ListView.builder(
        itemCount: bellSchedule.periods.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: const ScheduleDisplayListLegend(),
                  ),
                ],
              ),
            );
          }
          index -= 1;
          BellPeriod period = bellSchedule.periods[index];
          return ScheduleExpandableListItem(
            bellSchedule: bellSchedule,
            period: period,
            currentTime: currentTime,
            scheduleData: scheduleData,
          );
        },
      ),
    );
  }
}

class ScheduleExpandableListItem extends StatefulWidget {
  const ScheduleExpandableListItem({
    super.key,
    required this.bellSchedule,
    required this.period,
    required this.currentTime,
    required this.scheduleData,
  });

  final BellSchedule bellSchedule;
  final BellPeriod period;
  final DateTime currentTime;
  final ScheduleData scheduleData;

  @override
  State<ScheduleExpandableListItem> createState() =>
      _ScheduleExpandableListItemState();
}

class _ScheduleExpandableListItemState
    extends State<ScheduleExpandableListItem> {
  final double flashDurationMs = 3000;

  @override
  Widget build(BuildContext context) {
    TimeOfDay now = TimeOfDay.fromDateTime(widget.currentTime);
    ClassPeriod? course =
        widget.scheduleData.getCourseByPeriod(widget.period.periodName);
    String name = course == null
        ? widget.period.periodName
        : cleanClassName(course.courseTitle);

    String email = course?.teacherEmail ?? "N/A";

    bool subdueName = widget.period.endedBefore(now);
    bool subdueStart = isBAfterATimeOfDay(widget.period.startTime, now);
    bool subdueEnd = isBAfterATimeOfDay(widget.period.endTime, now);

    bool nextDuringPassing =
        widget.bellSchedule.isPassingPeriod(now).$3 == widget.period;

    bool isLunchOrFlex = course == null;

    return ExpandableListItem(
      unexpandedHeight: 60,
      expandedHeight: isLunchOrFlex ? 60 : 150,
      highlighted: widget.period.isHappening(now) || nextDuringPassing,
      // ignore: sort_child_properties_last
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          children: [
            Expanded(
              flex: 9,
              child: Text(
                name,
                style: subdueName ? bodyStyleBoldSubdued : bodyStyleBold,
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              flex: 2,
              child: nextDuringPassing
                  ? FlashingText(
                      text: removeAMPM(widget.period.startTime.format(context)),
                      textAlign: TextAlign.center,
                      style: subdueStart ? bodyStyleSubdued : bodyStyle,
                      durationMs: flashDurationMs,
                    )
                  : Text(
                      removeAMPM(widget.period.startTime.format(context)),
                      textAlign: TextAlign.center,
                      style: subdueStart ? bodyStyleSubdued : bodyStyle,
                    ),
            ),
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 2,
              child: Text(
                removeAMPM(widget.period.endTime.format(context)),
                textAlign: TextAlign.center,
                style: subdueEnd ? bodyStyleSubdued : bodyStyle,
              ),
            ),
          ],
        ),
      ),
      expandedChild: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.scheduleData
                            .getCourseByPeriod(widget.period.periodName)
                            ?.teacherName ??
                        "Teacher N/A",
                  ),
                  Text(
                    "Room ${widget.scheduleData.getCourseByPeriod(widget.period.periodName)?.roomName ?? "N/A"}",
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.email_sharp),
                    iconSize: 20,
                    padding: EdgeInsets.all(10),
                    onPressed: () {
                      // Link to email teacher
                      if (email != "N/A") {
                        final Uri params = Uri(
                          scheme: 'mailto',
                          path: email,
                        );
                        try {
                          launchUrl(params);
                        } catch (_) {
                          // Empty catch block because email can fail due to OS/package errors
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.book_sharp),
                    iconSize: 20,
                    padding: EdgeInsets.all(10),
                    onPressed: () {
                      // Send to gradebook page for that class
                      Provider.of<AppData>(context, listen: false)
                          .selectGradebookClass(
                              int.parse(widget.period.periodName) - 1);
                      Provider.of<AppData>(context, listen: false)
                          .changePage(AppPage.gradebook, animate: true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
