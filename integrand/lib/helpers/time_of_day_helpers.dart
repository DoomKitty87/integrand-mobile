import 'package:flutter/material.dart';


int toMinutesTimeOfDay(TimeOfDay timeOfDay) {
  return timeOfDay.hour * 60 + timeOfDay.minute;
}

int differenceMinutesTimeOfDay(TimeOfDay a, TimeOfDay b) {
  int aMinutes = toMinutesTimeOfDay(a);
  int bMinutes = toMinutesTimeOfDay(b);
  double difference = aMinutes.toDouble() - bMinutes.toDouble();
  return difference.floor();
}

bool isBetweenTimeOfDayInclusive(TimeOfDay start, TimeOfDay end, TimeOfDay test) {
  int aInt = toMinutesTimeOfDay(start);
  int bInt = toMinutesTimeOfDay(end);
  int testInt = toMinutesTimeOfDay(test);

  if (aInt <= testInt && testInt <= bInt) {
    return true;
  }
  return false;
}

int toMicrosecondsTimeOfDay(TimeOfDay time) {
  return Duration.microsecondsPerHour * time.hour + Duration.microsecondsPerMinute * time.minute;
}

int toMillisecondsTimeOfDay(TimeOfDay time) {
  return Duration.millisecondsPerHour * time.hour + Duration.millisecondsPerMinute * time.minute;
}

int differenceMicrosecondsDateTime(DateTime a, DateTime b) {
  return a.microsecondsSinceEpoch - b.microsecondsSinceEpoch;
}


int differenceMillisecondsDateTime(DateTime a, DateTime b) {
  return a.millisecondsSinceEpoch - b.millisecondsSinceEpoch;
}