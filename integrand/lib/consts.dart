import 'package:flutter/material.dart';
import 'package:integrand/backend/data_classes.dart';

const String appName = "Integrand";

const Color backgroundColor = Color.fromRGBO(13, 13, 13, 1); //HSVO(0, 0, 5, 1)
const Color textColor = Color.fromRGBO(224, 224, 224, 1);


// For testing
TimeOfDay periodEnd = const TimeOfDay(hour: 11, minute: 25);
bool isPassingPeriod = false;

BellSchedule testASchedule = BellSchedule.withValues(
  periods: [
    BellPeriod.withValues(periodName: "Period 1", startTime: TimeOfDay(hour: 8, minute: 30), endTime: TimeOfDay(hour: 10, minute: 2)),
    BellPeriod.withValues(periodName: "Period 2", startTime: TimeOfDay(hour: 10, minute: 9), endTime: TimeOfDay(hour: 11, minute: 41)),
    BellPeriod.withValues(periodName: "Lunch", startTime: TimeOfDay(hour: 11, minute: 41), endTime: TimeOfDay(hour: 12, minute: 14)), // this will cause problems
    BellPeriod.withValues(periodName: "Period 3", startTime: TimeOfDay(hour: 12, minute: 19), endTime: TimeOfDay(hour: 13, minute: 51)),
    BellPeriod.withValues(periodName: "Period 4", startTime: TimeOfDay(hour: 13, minute: 58), endTime: TimeOfDay(hour: 15, minute: 30)),
  ]
);

BellSchedule testBSchedule = BellSchedule.withValues(
  periods: [
    BellPeriod.withValues(periodName: "Period 5", startTime: TimeOfDay(hour: 8, minute: 30), endTime: TimeOfDay(hour: 10, minute: 2)),
    BellPeriod.withValues(periodName: "Period 6", startTime: TimeOfDay(hour: 10, minute: 9), endTime: TimeOfDay(hour: 11, minute: 41)),
    BellPeriod.withValues(periodName: "Lunch", startTime: TimeOfDay(hour: 11, minute: 41), endTime: TimeOfDay(hour: 12, minute: 14)), // this will cause problems
    BellPeriod.withValues(periodName: "Period 7", startTime: TimeOfDay(hour: 12, minute: 19), endTime: TimeOfDay(hour: 13, minute: 51)),
    BellPeriod.withValues(periodName: "Period 8", startTime: TimeOfDay(hour: 13, minute: 58), endTime: TimeOfDay(hour: 15, minute: 30)),
  ]
);

Map<String, String> periodNameToIndicator = {
  "Period 1" : "P1",
  "Period 2" : "P2",
  "Period 3" : "P3",
  "Period 4" : "P4",
  "Period 5" : "P5",
  "Period 6" : "P6",
  "Period 7" : "P7",
  "Period 8" : "P8",
  "Flex" : "FLX",
  "Lunch" : "L",
};
