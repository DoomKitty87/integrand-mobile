import 'package:flutter/material.dart';

import '../helpers/time_of_day_helpers.dart';

class Course {
  String courseTitle = '';
  String teacher = '';
  String teacherEmail = '';
  String room = '';
  String period = '';
}

class ScheduleData {
  List<Course> courses = [];
}

class Assignment {
  String title = '';
  double score = 0.0;
  double total = 0.0;

  double points = 0.0;
  double totalPoints = 0.0;

  AssignmentType type = AssignmentType(
    title: 'Default',
    weight: 1.0,
  );
}

class AssignmentType {
  String title = '';
  double weight = 0.0;

  double points = 0.0;
  double total = 0.0;

  AssignmentType({
    required this.title,
    required this.weight,
  });
}

class CourseGrading {
  String courseTitle = '';
  double grade = 0.0;
  List<AssignmentType> assignmentTypes = [];
  List<Assignment> assignments = [];
}

class GradebookData {
  List<CourseGrading> courses = [];
}

class GPAData {
  double unweightedGPA = 0.0;
  double weightedGPA = 0.0;

  int unweightedRank = 0;
  int weightedRank = 0;

  int totalStudents = 0;
}

class BellPeriod {
  String periodName = '';
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 0, minute: 0);

  BellPeriod();
  BellPeriod.withValues({required this.periodName, required this.startTime, required this.endTime});

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

  BellSchedule();
  BellSchedule.withValues({required this.periods});

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

class CourseEntry {
  String courseTitle = '';
  int grade = 0;
  bool isWeighted = false;
}

class CourseHistory {
  List<CourseEntry> courses = [];
}

class StudentVueWebData {
  String courseHistory = '';
  String classSchedule = '';
}

class StudentData {
  String name = '';
  int grade = 0;
  int studentId = 0;
  String school = '';
}
