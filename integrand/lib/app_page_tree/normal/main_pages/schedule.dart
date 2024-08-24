import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../helpers/time_of_day_helpers.dart';
import '../../../consts.dart';
import '../../../backend/data_classes.dart';

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

    setState(() {
      // TODO: Change this to change the timescale of the app
      _currentTime = DateTime.fromMillisecondsSinceEpoch(
          _currentTime.millisecondsSinceEpoch + 50000);
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
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: ScheduleTimeIndicators(
                bellSchedule: schedule,
                currentTime: _currentTime,
                periodNameToIndicatorMap: periodNameToIndicator,
              ),
            ),
            const SizedBox(
              height: 30,
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

  int expandedIndexManual = -1;
  int expandedIndexAutomatic = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, studentVueAPI, child) {
      textChildren.clear();

      // Set expanded index to that of the next or current period
      for (int i = 0; i < widget.bellSchedule.periods.length; i++) {
        if (widget.bellSchedule.periods[i]
            .isHappening(TimeOfDay.fromDateTime(widget.currentTime))) {
          expandedIndexAutomatic = i;
          break;
        }
      }

      if (expandedIndexAutomatic == -1) {
        for (int i = 0; i < widget.bellSchedule.periods.length - 1; i++) {
          BellPeriod period = widget.bellSchedule.periods[i];
          BellPeriod nextPeriod = widget.bellSchedule.periods[i + 1];

          if (isBetweenTimeOfDayInclusive(period.endTime, nextPeriod.startTime,
              TimeOfDay.fromDateTime(widget.currentTime))) {
            expandedIndexAutomatic = i + 1;
            break;
          }
        }
      }

      if (expandedIndexManual != -1) {
        expandedIndexAutomatic = -1;
      }

      // Border element
      // ignore: avoid_unnecessary_containers
      Container border = Container(
        child: const Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: BorderLine(),
        ),
      );
      textChildren.add(border);

      int i = 0;
      for (BellPeriod period in widget.bellSchedule.periods) {
        int index = i;
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
          child: TextButton(
            // Disable the button if it's lunch or flex`
            // onPressed: (isLunchOrFlex(name) ? null : () => toggleExpanded(index, name)),
            onPressed: () => toggleExpanded(index, name),

            style: TextButton.styleFrom(
              // TODO: Change onclick visuals
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: EdgeInsets.zero,
            ),
            child: SizedBox(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: isCurrentPeriod
                          ? textGradient
                          : (expandedIndexManual == index
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                      Colors.transparent,
                                      Colors.transparent
                                    ])
                              : const LinearGradient(colors: [
                                  Colors.transparent,
                                  Colors.transparent
                                ])),
                    ),
                    child: Padding(
                      padding: textPadding,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: 200.0,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  name,
                                  style: textStyle,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80.0,
                            child: Text(
                              period.startTime.format(context),
                              style: textStyle,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(
                            width: 80.0,
                            child: Text(
                              period.endTime.format(context),
                              style: textStyle,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if ((expandedIndexManual == index ||
                          expandedIndexAutomatic == index) &&
                      period.periodName != "Lunch" &&
                      period.periodName != "Flex")
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 25.0,
                        right: 25.0,
                        bottom: 14.0,
                        top: 14.0,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                              width: isCurrentPeriod ? 5.0 : 3.0,
                              height: 80,
                              decoration: isCurrentPeriod
                                  ? const BoxDecoration(
                                      gradient: verticalGradientAccent,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                    )
                                  : const BoxDecoration(
                                      color: lighterGrey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(3.0)),
                                    )),
                          const SizedBox(
                            width: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.room,
                                      color: iconColor,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      "Room ${course?.room ?? "N/A"}",
                                      style: bodyStyle,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.assignment_ind,
                                      color: iconColor,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      course?.teacher ?? "N/A",
                                      style: bodyStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // TODO: Fix overflow wrapping here
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
        );
        textChildren.add(nextPeriodText);

        if (widget.bellSchedule
            .isPassingPeriod(TimeOfDay.fromDateTime(widget.currentTime))
            .$1) {
          if (i < widget.bellSchedule.periods.length - 1) {
            // Check if the passing period is between the current period and the next period
            if (isBetweenTimeOfDayInclusive(
                widget.bellSchedule.periods[i].endTime,
                widget.bellSchedule.periods[i + 1].startTime,
                TimeOfDay.fromDateTime(widget.currentTime))) {
              border = Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: textGradient,
                    ),
                  ),
                ),
              );
            } else {
              border = Container(
                child: const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: BorderLine(),
                ),
              );
            }
          }
        }

        if (i != widget.bellSchedule.periods.length - 1) {
          textChildren.add(border);
        } else {
          // Prevents the final border line from lighting up
          border = Container(
            child: const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: BorderLine(),
            ),
          );

          textChildren.add(border); // Adds a border line between each period
        }
        i++;
      }

      return Column(
        children: textChildren,
      );
    });
  }

  bool isLunchOrFlex(String name) {
    return name == "Lunch" || name == "Flex";
  }

  void toggleExpanded(int index, String name) {
    if (isLunchOrFlex(name)) {
      return;
    }
    setState(() {
      if (expandedIndexManual == index) {
        expandedIndexManual = -1;
      } else {
        expandedIndexManual = index;
      }
    });
  }
}
