/// This file contains all of the data classes related to scheduling.
/// This is exported to the rest of the app by data_classes.dart.
library data_classes.schedule;

import 'package:flutter/material.dart';
import '/../../helpers/time_of_day_helpers.dart';

class ScheduleData {
  List<ClassPeriod> courses = [];
  bool error = false;

  ClassPeriod? getCourseByPeriod(String period) {
    for (var course in courses) {
      if (course.periodNum == period) {
        return course;
      }
    }
    return null;
  }

  ScheduleData();

  ScheduleData.testData() {
    courses = [
      ClassPeriod.withValues(
          courseTitle: 'AP Calculus BC',
          teacherName: 'Mr. Smith',
          teacherEmail: 'email@student.pps.net',
          roomName: '123',
          periodNum: '1'),
      ClassPeriod.withValues(
          courseTitle: 'AP Physics C',
          teacherName: 'Mr. Johnson',
          teacherEmail: 'email@student.pps.net',
          roomName: '456',
          periodNum: '2'),
      ClassPeriod.withValues(
          courseTitle: 'AP Computer Science A',
          teacherName: 'Mr. Doe',
          teacherEmail: 'email@student.pps.net',
          roomName: '789',
          periodNum: '3'),
      ClassPeriod.withValues(
          courseTitle: 'AP English Literature',
          teacherName: 'Ms. Smith',
          teacherEmail: 'email@student.pps.net',
          roomName: '101',
          periodNum: '4'),
      ClassPeriod.withValues(
          courseTitle: 'AP US History',
          teacherName: 'Mr. Johnson',
          teacherEmail: 'email@student.pps.net',
          roomName: '202',
          periodNum: '5'),
      ClassPeriod.withValues(
          courseTitle: 'AP Chemistry',
          teacherName: 'Mr. Doe',
          teacherEmail: 'email@student.pps.net',
          roomName: '303',
          periodNum: '6'),
      ClassPeriod.withValues(
          courseTitle: 'AP Spanish',
          teacherName: 'Ms. Smith',
          teacherEmail: 'email@student.pps.net',
          roomName: '404',
          periodNum: '7'),
      ClassPeriod.withValues(
          courseTitle: 'AP Art History',
          teacherName: 'Mr. Johnson',
          teacherEmail: 'email@student.pps.net',
          roomName: '505',
          periodNum: '8'),
    ];
  }
}

class ClassPeriod {
  String courseTitle = '';
  String teacherName = '';
  String teacherEmail = '';
  /// Room contains 'Room' and room number
  String roomName = '';
  String periodNum = '';

  ClassPeriod();
  ClassPeriod.withValues({
    required this.courseTitle,
    required this.teacherName,
    required this.teacherEmail,
    required this.roomName,
    required this.periodNum,
  });
}

class BellPeriod {
  String periodName = '';
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 0, minute: 0);

  BellPeriod();
  BellPeriod.withValues({
    required this.periodName,
    required this.startTime,
    required this.endTime,
  });

  bool willStartAfter(TimeOfDay time) {
    return toMinutesTimeOfDay(time) < toMinutesTimeOfDay(startTime);
  }

  bool isHappening(TimeOfDay time) {
    return isBetweenTimeOfDayInclusive(startTime, endTime, time);
  }

  bool endedBefore(TimeOfDay time) {
    return toMinutesTimeOfDay(endTime) < toMinutesTimeOfDay(time);
  }
}

class BellSchedule {
  List<BellPeriod> periods = [];
  bool error = false;

  BellSchedule();
  BellSchedule.withValues({required this.periods});
  BellSchedule.testDataA() {
    periods = [
      BellPeriod.withValues(
          periodName: "1",
          startTime: const TimeOfDay(hour: 8, minute: 30),
          endTime: const TimeOfDay(hour: 10, minute: 2)),
      BellPeriod.withValues(
          periodName: "2",
          startTime: const TimeOfDay(hour: 10, minute: 9),
          endTime: const TimeOfDay(hour: 11, minute: 41)),
      BellPeriod.withValues(
          periodName: "Lunch",
          startTime: const TimeOfDay(hour: 11, minute: 41),
          endTime: const TimeOfDay(hour: 12, minute: 14)),
      BellPeriod.withValues(
          periodName: "3",
          startTime: const TimeOfDay(hour: 12, minute: 19),
          endTime: const TimeOfDay(hour: 13, minute: 51)),
      BellPeriod.withValues(
          periodName: "4",
          startTime: const TimeOfDay(hour: 13, minute: 58),
          endTime: const TimeOfDay(hour: 15, minute: 30)),
    ];
  }

  BellSchedule.testDataB() {
    periods = [
      BellPeriod.withValues(
          periodName: "5",
          startTime: const TimeOfDay(hour: 8, minute: 30),
          endTime: const TimeOfDay(hour: 10, minute: 2)),
      BellPeriod.withValues(
          periodName: "6",
          startTime: const TimeOfDay(hour: 10, minute: 9),
          endTime: const TimeOfDay(hour: 11, minute: 41)),
      BellPeriod.withValues(
          periodName: "Lunch",
          startTime: const TimeOfDay(hour: 11, minute: 41),
          endTime: const TimeOfDay(hour: 12, minute: 14)),
      BellPeriod.withValues(
          periodName: "7",
          startTime: const TimeOfDay(hour: 12, minute: 19),
          endTime: const TimeOfDay(hour: 13, minute: 51)),
      BellPeriod.withValues(
          periodName: "8",
          startTime: const TimeOfDay(hour: 13, minute: 58),
          endTime: const TimeOfDay(hour: 15, minute: 30)),
    ];
  }

  BellSchedule.testDataAll8() {
    periods = [
      BellPeriod.withValues(
        periodName: "1",
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 10, minute: 2),
      ),
      BellPeriod.withValues(
        periodName: "2",
        startTime: const TimeOfDay(hour: 10, minute: 9),
        endTime: const TimeOfDay(hour: 11, minute: 41),
      ),
      BellPeriod.withValues(
        periodName: "3",
        startTime: const TimeOfDay(hour: 12, minute: 19),
        endTime: const TimeOfDay(hour: 13, minute: 51),
      ),
      BellPeriod.withValues(
        periodName: "4",
        startTime: const TimeOfDay(hour: 13, minute: 58),
        endTime: const TimeOfDay(hour: 15, minute: 30),
      ),
      BellPeriod.withValues(
        periodName: "Lunch",
        startTime: const TimeOfDay(hour: 11, minute: 41),
        endTime: const TimeOfDay(hour: 12, minute: 14),
      ),
      BellPeriod.withValues(
        periodName: "5",
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 10, minute: 2),
      ),
      BellPeriod.withValues(
        periodName: "6",
        startTime: const TimeOfDay(hour: 10, minute: 9),
        endTime: const TimeOfDay(hour: 11, minute: 41),
      ),
      BellPeriod.withValues(
        periodName: "Lunch",
        startTime: const TimeOfDay(hour: 11, minute: 41),
        endTime: const TimeOfDay(hour: 12, minute: 14),
      ),
      BellPeriod.withValues(
        periodName: "7",
        startTime: const TimeOfDay(hour: 12, minute: 19),
        endTime: const TimeOfDay(hour: 13, minute: 51),
      ),
      BellPeriod.withValues(
        periodName: "8",
        startTime: const TimeOfDay(hour: 13, minute: 58),
        endTime: const TimeOfDay(hour: 15, minute: 30),
      ),
    ];
  }

  BellPeriod? getCurrentPeriod(TimeOfDay now) {
    for (var period in periods) {
      if (period.isHappening(now) == true) {
        return period;
      }
    }
    return null;
  }

  BellPeriod? getPreviousPeriod(TimeOfDay now) {
    if (periods.isEmpty) return null;

    BellPeriod? lastPeriod;
    for (int i = 0; i < periods.length; i++) {
      if (periods[i].endedBefore(now)) {
        lastPeriod = periods[i];
      }
    }
    return lastPeriod;
  }

  BellPeriod? getNextPeriod(TimeOfDay now) {
    if (periods.isEmpty) return null;

    for (int i = 0; i < periods.length; i++) {
      if (periods[i].willStartAfter(now)) {
        return periods[i];
      }
    }
    return null;
  }

  (bool, BellPeriod?, BellPeriod?) isPassingPeriod(TimeOfDay now) {
    if (periods.isEmpty) return (false, null, null);

    // If within period check
    for (var period in periods) {
      if (period.isHappening(now)) {
        return (false, null, null);
      }
    }

    // If after or before school
    if (isOutsideSchoolHours(now)) {
      return (false, null, null);
    }

    return (true, getPreviousPeriod(now), getNextPeriod(now));
  }

  bool isOutsideSchoolHours(TimeOfDay now) {
    if (periods.isEmpty) return true;

    if (periods.first.willStartAfter(now) || periods.last.endedBefore(now)) {
      return true;
    }
    return false;
  }
}