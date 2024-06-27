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