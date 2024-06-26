import 'package:flutter/material.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'helpers/time_of_day_helpers.dart';
import 'consts.dart';


// Main Widget
// ============================================================================================

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  
  bool isPassingPeriod = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(
      builder: (context, value, child) {
        
        // TODO: Get backend here

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ScheduleTimeIndicators(
                isPassingPeriod: isPassingPeriod, 
                periodEnd: periodEnd,
              ),
            ],
          ),
        );
      }
    );
  }
}

class ScheduleTimeIndicators extends StatefulWidget {
  const ScheduleTimeIndicators({super.key, required this.isPassingPeriod, required this.periodEnd});

  final bool isPassingPeriod;
  final TimeOfDay periodEnd;

  @override
  State<ScheduleTimeIndicators> createState() => _ScheduleTimeIndicatorsState();
}

class _ScheduleTimeIndicatorsState extends State<ScheduleTimeIndicators> {
  late Timer _timer;
  DateTime _dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) => _update());
  }

  void _update() {
    setState(() {
      _dateTime = DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer.cancel;
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClockTimerHybrid(
              currentDateTime: _dateTime,
            ),
            const PeriodIndicator(indicatorText: "P1"),
          ],
        ),
        Row(
          children: [
            MinutesLeftText(
              isPassingPeriod: widget.isPassingPeriod,
              periodEndTime: widget.periodEnd,
            ),
          ],
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
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
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

class MinutesLeftText extends StatelessWidget {
  const MinutesLeftText({super.key, required this.isPassingPeriod, required this.periodEndTime});

  final bool isPassingPeriod;
  final TimeOfDay periodEndTime;

  @override
  Widget build(BuildContext context) {
    String textString;
    
    if (isPassingPeriod) {
      textString = "minutes left";
    }
    else {
      int minutesLeft = differenceMinutesTimeOfDay(TimeOfDay.now(), periodEndTime);
      textString = "${minutesLeft} ${minutesLeft == 1 ? "minute left" : "minutes left"}";
    }

    return Text(
      textString,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

// TODO: Finish time left bar

class TimeLeftBar extends StatelessWidget {
  const TimeLeftBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [

      ],
    );
  }
}


class PeriodStartTime extends StatelessWidget {
  const PeriodStartTime({super.key, required this.period});

  final BellPeriod period;
  
  @override
  Widget build(BuildContext context) {
    return Text(
      period.startTime.format(context),
      textAlign: TextAlign.center,
    );
  }
}

class TimeLeftBarBackground extends StatelessWidget {
  const TimeLeftBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 1,
          color: textColor,
        ),
        Container(
          height: 1,
          color: textColor,
        ),
        Container(
          width: 1,
          color: textColor,
        ),
      ],
    );
  }
}