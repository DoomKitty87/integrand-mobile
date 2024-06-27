import 'package:flutter/material.dart';
import 'package:integrand/backend/data_classes.dart';

const String appName = "Integrand";

const Color backgroundColor = Color.fromRGBO(13, 13, 13, 1); //HSVO(0, 0, 5, 1)
const Color textColor = Color.fromRGBO(224, 224, 224, 1);
const Color darkGrey = Color.fromRGBO(50, 50, 50, 1);

const TextStyle titleStyle = TextStyle(
  color: textColor,
  fontSize: 48,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
);

const TextStyle subtitleStyle = TextStyle(
  color: textColor,
  fontSize: 48,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
);

const TextStyle bodyStyle = TextStyle(
  color: textColor,
  fontSize: 16,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
);

const TextStyle boldBodyStyle = TextStyle(
  color: textColor,
  fontSize: 16,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
);

const TextStyle smallBodyStyle = TextStyle(
  color: textColor,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
);

// For testing
TimeOfDay periodEnd = const TimeOfDay(hour: 11, minute: 25);

DateTime testDateTime = DateTime(
  2024,
  1,
  1,
  10,
  23,
  1,
  1,
  1,
);

BellSchedule testASchedule = BellSchedule.withValues(
  periods: [
    BellPeriod.withValues(periodName: "1", startTime: const TimeOfDay(hour: 8, minute: 30), endTime: TimeOfDay(hour: 10, minute: 2)),
    BellPeriod.withValues(periodName: "2", startTime: const TimeOfDay(hour: 10, minute: 9), endTime: TimeOfDay(hour: 11, minute: 41)),
    BellPeriod.withValues(periodName: "Lunch", startTime: const TimeOfDay(hour: 11, minute: 41), endTime: TimeOfDay(hour: 12, minute: 14)), // this will cause problems
    BellPeriod.withValues(periodName: "3", startTime: const TimeOfDay(hour: 12, minute: 19), endTime: TimeOfDay(hour: 13, minute: 51)),
    BellPeriod.withValues(periodName: "4", startTime: const TimeOfDay(hour: 13, minute: 58), endTime: TimeOfDay(hour: 15, minute: 30)),
  ]
);

BellSchedule testBSchedule = BellSchedule.withValues(
  periods: [
    BellPeriod.withValues(periodName: "5", startTime: const TimeOfDay(hour: 8, minute: 30), endTime: TimeOfDay(hour: 10, minute: 2)),
    BellPeriod.withValues(periodName: "6", startTime: const TimeOfDay(hour: 10, minute: 9), endTime: TimeOfDay(hour: 11, minute: 41)),
    BellPeriod.withValues(periodName: "Lunch", startTime: const TimeOfDay(hour: 11, minute: 41), endTime: TimeOfDay(hour: 12, minute: 14)), // this will cause problems
    BellPeriod.withValues(periodName: "7", startTime: const TimeOfDay(hour: 12, minute: 19), endTime: TimeOfDay(hour: 13, minute: 51)),
    BellPeriod.withValues(periodName: "8", startTime: const TimeOfDay(hour: 13, minute: 58), endTime: TimeOfDay(hour: 15, minute: 30)),
  ]
);

Map<String, String> periodNameToIndicator = {
  "1" : "P1",
  "2" : "P2",
  "3" : "P3",
  "4" : "P4",
  "5" : "P5",
  "6" : "P6",
  "7" : "P7",
  "8" : "P8",
  "Flex" : "FLX",
  "Lunch" : "L",
  "" : "PASS"
};

