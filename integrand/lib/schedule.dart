import 'package:flutter/material.dart';
import 'dart:async';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  
  bool isPassingPeriod = false;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: const EdgeInsets.all(8.0),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClockTimerHybrid(),
            ],
          )
        ],
      ),
    );
  }
}

class ClockTimerHybrid extends StatefulWidget {
  const ClockTimerHybrid({super.key});

  @override
  State<ClockTimerHybrid> createState() => _ClockTimerHybridState();
}

class _ClockTimerHybridState extends State<ClockTimerHybrid> {

  late Timer _timer;
  DateTime _dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) => _update());
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
    return Text(
      "${_dateTime.minute}:${_dateTime.second}",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
      ),
    );
  }
}