import 'package:flutter/material.dart';


int toMinutesTimeOfDay(TimeOfDay timeOfDay) {
  return timeOfDay.hour * 60 + timeOfDay.minute;
}

bool isBAfterATimeOfDay(TimeOfDay a, TimeOfDay b) {
  int aInt = toMinutesTimeOfDay(a);
  int bInt = toMinutesTimeOfDay(b);
  return bInt > aInt;
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

String weekdayToName(int dateTimeWeekday) {
  List<String> daysOfWeek = const [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  return daysOfWeek[dateTimeWeekday - 1];
}

String monthToName(int dateTimeMonth, {bool short = false}) {
  List<String> months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<String> shortMonths = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  if (short) {
    return shortMonths[dateTimeMonth - 1];
  }
  else {
    return months[dateTimeMonth - 1];
  }
}

String numberWithSuffix(int number) {
  if (number >= 11 && number <= 13) {
    return '$number' + 'th';
  }
  switch (number % 10) {
    case 1:
      return '$number' + 'st';
    case 2:
      return '$number' + 'nd';
    case 3:
      return '$number' + 'rd';
    default:
      return '$number' + 'th';
  }
}

class TimeOfDayPrecise {
  TimeOfDayPrecise();
  TimeOfDayPrecise.fromTimeOfDay(TimeOfDay timeOfDay) {
    hour = timeOfDay.hour;
    minute = timeOfDay.minute;
    second = 0;
    millisecond = 0;
  }
  TimeOfDayPrecise.fromDateTime(DateTime dateTime) {
    hour = dateTime.hour;
    minute = dateTime.minute;
    second = dateTime.second;
    millisecond = dateTime.millisecond;
  }
  TimeOfDayPrecise.fromMilliseconds(int milliseconds) {
    hour = milliseconds ~/ Duration.millisecondsPerHour;
    minute = (milliseconds % Duration.millisecondsPerHour) ~/ Duration.millisecondsPerMinute;
    second = (milliseconds % Duration.millisecondsPerMinute) ~/ Duration.millisecondsPerSecond;
    millisecond = milliseconds % Duration.millisecondsPerSecond;
  }
  int toMilliseconds() {
    return Duration.millisecondsPerHour * hour + Duration.millisecondsPerMinute * minute + Duration.millisecondsPerSecond * second + millisecond;
  }

  int hour = 0;
  int minute = 0;
  int second = 0;
  int millisecond = 0;

  

  @override
  String toString() {
    return '$hour:$minute:$second.$millisecond';
  }
}